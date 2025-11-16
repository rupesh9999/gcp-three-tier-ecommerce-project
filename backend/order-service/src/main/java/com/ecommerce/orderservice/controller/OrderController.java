package com.ecommerce.orderservice.controller;

import com.ecommerce.orderservice.dto.CreateOrderRequest;
import com.ecommerce.orderservice.dto.OrderDTO;
import com.ecommerce.orderservice.entity.Order;
import com.ecommerce.orderservice.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/orders")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Slf4j
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    public ResponseEntity<OrderDTO> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        log.info("Creating order for user: {}", request.getUserId());
        OrderDTO order = orderService.createOrder(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(order);
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderDTO> getOrderById(@PathVariable Long id) {
        log.info("Fetching order by id: {}", id);
        OrderDTO order = orderService.getOrderById(id);
        return ResponseEntity.ok(order);
    }

    @GetMapping("/number/{orderNumber}")
    public ResponseEntity<OrderDTO> getOrderByOrderNumber(@PathVariable String orderNumber) {
        log.info("Fetching order by order number: {}", orderNumber);
        OrderDTO order = orderService.getOrderByOrderNumber(orderNumber);
        return ResponseEntity.ok(order);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<Page<OrderDTO>> getOrdersByUserId(
            @PathVariable Long userId,
            Pageable pageable) {
        log.info("Fetching orders for user: {}", userId);
        Page<OrderDTO> orders = orderService.getOrdersByUserId(userId, pageable);
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<Page<OrderDTO>> getOrdersByStatus(
            @PathVariable Order.OrderStatus status,
            Pageable pageable) {
        log.info("Fetching orders with status: {}", status);
        Page<OrderDTO> orders = orderService.getOrdersByStatus(status, pageable);
        return ResponseEntity.ok(orders);
    }

    @GetMapping
    public ResponseEntity<Page<OrderDTO>> getAllOrders(Pageable pageable) {
        log.info("Fetching all orders");
        Page<OrderDTO> orders = orderService.getAllOrders(pageable);
        return ResponseEntity.ok(orders);
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<OrderDTO> updateOrderStatus(
            @PathVariable Long id,
            @RequestParam Order.OrderStatus status,
            @RequestParam(required = false) String notes,
            @RequestParam(defaultValue = "SYSTEM") String changedBy) {
        log.info("Updating order {} status to {}", id, status);
        OrderDTO order = orderService.updateOrderStatus(id, status, notes, changedBy);
        return ResponseEntity.ok(order);
    }

    @PatchMapping("/{id}/tracking")
    public ResponseEntity<OrderDTO> updateTrackingNumber(
            @PathVariable Long id,
            @RequestParam String trackingNumber) {
        log.info("Updating tracking number for order {}: {}", id, trackingNumber);
        OrderDTO order = orderService.updateTrackingNumber(id, trackingNumber);
        return ResponseEntity.ok(order);
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<OrderDTO> cancelOrder(
            @PathVariable Long id,
            @RequestParam(required = false) String reason,
            @RequestParam(defaultValue = "USER") String cancelledBy) {
        log.info("Cancelling order {}", id);
        OrderDTO order = orderService.cancelOrder(id, reason, cancelledBy);
        return ResponseEntity.ok(order);
    }
}
