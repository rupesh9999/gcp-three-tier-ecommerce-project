package com.ecommerce.orderservice.service;

import com.ecommerce.orderservice.dto.CreateOrderRequest;
import com.ecommerce.orderservice.dto.OrderDTO;
import com.ecommerce.orderservice.dto.OrderItemDTO;
import com.ecommerce.orderservice.entity.Order;
import com.ecommerce.orderservice.entity.OrderItem;
import com.ecommerce.orderservice.entity.OrderStatusHistory;
import com.ecommerce.orderservice.repository.OrderRepository;
import com.ecommerce.orderservice.repository.OrderStatusHistoryRepository;
import com.google.cloud.spring.pubsub.core.PubSubTemplate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderService {

    private final OrderRepository orderRepository;
    private final OrderStatusHistoryRepository statusHistoryRepository;
    private final PubSubTemplate pubSubTemplate;

    @Value("${gcp.pubsub.topic.order-created:order-created}")
    private String orderCreatedTopic;

    @Value("${gcp.pubsub.topic.order-status-changed:order-status-changed}")
    private String orderStatusChangedTopic;

    @Transactional
    public OrderDTO createOrder(CreateOrderRequest request) {
        log.info("Creating order for user: {}", request.getUserId());

        // Create order entity
        Order order = new Order();
        order.setOrderNumber(generateOrderNumber());
        order.setUserId(request.getUserId());
        order.setUserEmail(request.getUserEmail());
        order.setStatus(Order.OrderStatus.PENDING);
        order.setPaymentMethod(request.getPaymentMethod());
        order.setPaymentStatus("PENDING");
        order.setNotes(request.getNotes());

        // Set shipping address
        order.setShippingAddressLine1(request.getShippingAddressLine1());
        order.setShippingAddressLine2(request.getShippingAddressLine2());
        order.setShippingCity(request.getShippingCity());
        order.setShippingState(request.getShippingState());
        order.setShippingCountry(request.getShippingCountry());
        order.setShippingPostalCode(request.getShippingPostalCode());

        // Calculate totals
        BigDecimal subtotal = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;
        BigDecimal totalDiscount = BigDecimal.ZERO;

        for (CreateOrderRequest.OrderItemRequest itemRequest : request.getItems()) {
            OrderItem item = new OrderItem();
            item.setProductId(itemRequest.getProductId());
            item.setProductSku(itemRequest.getProductSku());
            item.setProductName(itemRequest.getProductName());
            item.setQuantity(itemRequest.getQuantity());
            item.setUnitPrice(itemRequest.getUnitPrice());
            item.setDiscountAmount(itemRequest.getDiscountAmount() != null ? itemRequest.getDiscountAmount() : BigDecimal.ZERO);
            item.setTaxAmount(itemRequest.getTaxAmount() != null ? itemRequest.getTaxAmount() : BigDecimal.ZERO);

            BigDecimal itemTotal = itemRequest.getUnitPrice()
                    .multiply(BigDecimal.valueOf(itemRequest.getQuantity()))
                    .subtract(item.getDiscountAmount())
                    .add(item.getTaxAmount());
            item.setTotalPrice(itemTotal);

            order.addItem(item);

            subtotal = subtotal.add(itemRequest.getUnitPrice().multiply(BigDecimal.valueOf(itemRequest.getQuantity())));
            totalTax = totalTax.add(item.getTaxAmount());
            totalDiscount = totalDiscount.add(item.getDiscountAmount());
        }

        order.setSubtotal(subtotal);
        order.setTaxAmount(totalTax);
        order.setShippingAmount(BigDecimal.ZERO); // Calculate based on shipping rules
        order.setDiscountAmount(totalDiscount);
        order.setTotalAmount(subtotal.subtract(totalDiscount).add(totalTax).add(order.getShippingAmount()));

        // Add initial status history
        OrderStatusHistory statusHistory = new OrderStatusHistory();
        statusHistory.setStatus(Order.OrderStatus.PENDING);
        statusHistory.setNotes("Order created");
        statusHistory.setChangedBy("SYSTEM");
        order.addStatusHistory(statusHistory);

        // Save order
        Order savedOrder = orderRepository.save(order);

        // Publish order created event
        publishOrderCreatedEvent(savedOrder);

        log.info("Order created successfully: {}", savedOrder.getOrderNumber());
        return mapToDTO(savedOrder);
    }

    @Transactional(readOnly = true)
    public OrderDTO getOrderById(Long id) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + id));
        return mapToDTO(order);
    }

    @Transactional(readOnly = true)
    public OrderDTO getOrderByOrderNumber(String orderNumber) {
        Order order = orderRepository.findByOrderNumber(orderNumber)
                .orElseThrow(() -> new RuntimeException("Order not found with order number: " + orderNumber));
        return mapToDTO(order);
    }

    @Transactional(readOnly = true)
    public Page<OrderDTO> getOrdersByUserId(Long userId, Pageable pageable) {
        return orderRepository.findByUserId(userId, pageable)
                .map(this::mapToDTO);
    }

    @Transactional(readOnly = true)
    public Page<OrderDTO> getOrdersByStatus(Order.OrderStatus status, Pageable pageable) {
        return orderRepository.findByStatus(status, pageable)
                .map(this::mapToDTO);
    }

    @Transactional(readOnly = true)
    public Page<OrderDTO> getAllOrders(Pageable pageable) {
        return orderRepository.findAll(pageable)
                .map(this::mapToDTO);
    }

    @Transactional
    public OrderDTO updateOrderStatus(Long id, Order.OrderStatus newStatus, String notes, String changedBy) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + id));

        Order.OrderStatus oldStatus = order.getStatus();
        order.setStatus(newStatus);

        // Update timestamps based on status
        switch (newStatus) {
            case SHIPPED:
                order.setShippedAt(LocalDateTime.now());
                break;
            case DELIVERED:
                order.setDeliveredAt(LocalDateTime.now());
                break;
            case CANCELLED:
                order.setCancelledAt(LocalDateTime.now());
                order.setCancellationReason(notes);
                break;
        }

        // Add status history
        OrderStatusHistory statusHistory = new OrderStatusHistory();
        statusHistory.setStatus(newStatus);
        statusHistory.setNotes(notes);
        statusHistory.setChangedBy(changedBy);
        order.addStatusHistory(statusHistory);

        Order savedOrder = orderRepository.save(order);

        // Publish status changed event
        publishOrderStatusChangedEvent(savedOrder, oldStatus, newStatus);

        log.info("Order {} status updated from {} to {}", order.getOrderNumber(), oldStatus, newStatus);
        return mapToDTO(savedOrder);
    }

    @Transactional
    public OrderDTO updateTrackingNumber(Long id, String trackingNumber) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found with id: " + id));

        order.setTrackingNumber(trackingNumber);
        Order savedOrder = orderRepository.save(order);

        log.info("Tracking number updated for order {}: {}", order.getOrderNumber(), trackingNumber);
        return mapToDTO(savedOrder);
    }

    @Transactional
    public OrderDTO cancelOrder(Long id, String reason, String cancelledBy) {
        return updateOrderStatus(id, Order.OrderStatus.CANCELLED, reason, cancelledBy);
    }

    private void publishOrderCreatedEvent(Order order) {
        try {
            String message = String.format("{\"orderId\":%d,\"orderNumber\":\"%s\",\"userId\":%d,\"totalAmount\":%s,\"status\":\"%s\"}",
                    order.getId(), order.getOrderNumber(), order.getUserId(), order.getTotalAmount(), order.getStatus());
            pubSubTemplate.publish(orderCreatedTopic, message);
            log.info("Published order created event for order: {}", order.getOrderNumber());
        } catch (Exception e) {
            log.error("Failed to publish order created event", e);
        }
    }

    private void publishOrderStatusChangedEvent(Order order, Order.OrderStatus oldStatus, Order.OrderStatus newStatus) {
        try {
            String message = String.format("{\"orderId\":%d,\"orderNumber\":\"%s\",\"oldStatus\":\"%s\",\"newStatus\":\"%s\"}",
                    order.getId(), order.getOrderNumber(), oldStatus, newStatus);
            pubSubTemplate.publish(orderStatusChangedTopic, message);
            log.info("Published order status changed event for order: {}", order.getOrderNumber());
        } catch (Exception e) {
            log.error("Failed to publish order status changed event", e);
        }
    }

    private String generateOrderNumber() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String random = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        return "ORD-" + timestamp + "-" + random;
    }

    private OrderDTO mapToDTO(Order order) {
        OrderDTO dto = new OrderDTO();
        dto.setId(order.getId());
        dto.setOrderNumber(order.getOrderNumber());
        dto.setUserId(order.getUserId());
        dto.setUserEmail(order.getUserEmail());
        dto.setStatus(order.getStatus());
        dto.setSubtotal(order.getSubtotal());
        dto.setTaxAmount(order.getTaxAmount());
        dto.setShippingAmount(order.getShippingAmount());
        dto.setDiscountAmount(order.getDiscountAmount());
        dto.setTotalAmount(order.getTotalAmount());
        dto.setPaymentMethod(order.getPaymentMethod());
        dto.setPaymentStatus(order.getPaymentStatus());
        dto.setShippingAddressLine1(order.getShippingAddressLine1());
        dto.setShippingAddressLine2(order.getShippingAddressLine2());
        dto.setShippingCity(order.getShippingCity());
        dto.setShippingState(order.getShippingState());
        dto.setShippingCountry(order.getShippingCountry());
        dto.setShippingPostalCode(order.getShippingPostalCode());
        dto.setNotes(order.getNotes());
        dto.setTrackingNumber(order.getTrackingNumber());
        dto.setShippedAt(order.getShippedAt());
        dto.setDeliveredAt(order.getDeliveredAt());
        dto.setCancelledAt(order.getCancelledAt());
        dto.setCancellationReason(order.getCancellationReason());
        dto.setCreatedAt(order.getCreatedAt());
        dto.setUpdatedAt(order.getUpdatedAt());

        List<OrderItemDTO> itemDTOs = order.getItems().stream()
                .map(this::mapItemToDTO)
                .collect(Collectors.toList());
        dto.setItems(itemDTOs);

        return dto;
    }

    private OrderItemDTO mapItemToDTO(OrderItem item) {
        OrderItemDTO dto = new OrderItemDTO();
        dto.setId(item.getId());
        dto.setProductId(item.getProductId());
        dto.setProductSku(item.getProductSku());
        dto.setProductName(item.getProductName());
        dto.setQuantity(item.getQuantity());
        dto.setUnitPrice(item.getUnitPrice());
        dto.setDiscountAmount(item.getDiscountAmount());
        dto.setTaxAmount(item.getTaxAmount());
        dto.setTotalPrice(item.getTotalPrice());
        dto.setCreatedAt(item.getCreatedAt());
        return dto;
    }
}
