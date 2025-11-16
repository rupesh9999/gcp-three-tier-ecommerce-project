package com.ecommerce.productservice.service;

import com.ecommerce.productservice.dto.CategoryDTO;
import com.ecommerce.productservice.dto.ProductDTO;
import com.ecommerce.productservice.entity.Category;
import com.ecommerce.productservice.entity.Product;
import com.ecommerce.productservice.repository.CategoryRepository;
import com.ecommerce.productservice.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class ProductService {
    
    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    
    @Cacheable(value = "products", key = "#id")
    public ProductDTO getProductById(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        return mapToDTO(product);
    }
    
    public ProductDTO getProductBySku(String sku) {
        Product product = productRepository.findBySku(sku)
                .orElseThrow(() -> new RuntimeException("Product not found with SKU: " + sku));
        return mapToDTO(product);
    }
    
    public Page<ProductDTO> getAllProducts(Pageable pageable) {
        return productRepository.findByIsActiveTrue(pageable).map(this::mapToDTO);
    }
    
    public Page<ProductDTO> getProductsByCategory(Long categoryId, Pageable pageable) {
        return productRepository.findByCategoryIdAndIsActiveTrue(categoryId, pageable)
                .map(this::mapToDTO);
    }
    
    public Page<ProductDTO> getFeaturedProducts(Pageable pageable) {
        return productRepository.findByIsFeaturedTrueAndIsActiveTrue(pageable)
                .map(this::mapToDTO);
    }
    
    public Page<ProductDTO> searchProducts(String keyword, Pageable pageable) {
        return productRepository.searchProducts(keyword, pageable).map(this::mapToDTO);
    }
    
    @Transactional
    @CacheEvict(value = "products", allEntries = true)
    public ProductDTO createProduct(ProductDTO productDTO) {
        Product product = new Product();
        mapFromDTO(productDTO, product);
        
        Product savedProduct = productRepository.save(product);
        log.info("Product created: {}", savedProduct.getId());
        
        return mapToDTO(savedProduct);
    }
    
    @Transactional
    @CacheEvict(value = "products", key = "#id")
    public ProductDTO updateProduct(Long id, ProductDTO productDTO) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        mapFromDTO(productDTO, product);
        Product updatedProduct = productRepository.save(product);
        
        log.info("Product updated: {}", updatedProduct.getId());
        return mapToDTO(updatedProduct);
    }
    
    @Transactional
    public void updateStock(Long id, Integer quantity) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        product.setQuantity(product.getQuantity() + quantity);
        productRepository.save(product);
        
        log.info("Product stock updated: {} - New quantity: {}", id, product.getQuantity());
    }
    
    public List<Product> getLowStockProducts() {
        return productRepository.findByQuantityLessThanAndIsActiveTrue(10);
    }
    
    public List<CategoryDTO> getAllCategories() {
        return categoryRepository.findByParentIsNullAndIsActiveTrue()
                .stream()
                .map(this::mapCategoryToDTO)
                .collect(Collectors.toList());
    }
    
    private CategoryDTO mapCategoryToDTO(Category category) {
        CategoryDTO dto = new CategoryDTO();
        dto.setId(category.getId());
        dto.setName(category.getName());
        dto.setSlug(category.getSlug());
        dto.setDescription(category.getDescription());
        dto.setIconUrl(category.getIconUrl());
        dto.setParentId(category.getParent() != null ? category.getParent().getId() : null);
        dto.setIsActive(category.getIsActive());
        dto.setCreatedAt(category.getCreatedAt());
        dto.setUpdatedAt(category.getUpdatedAt());
        return dto;
    }
    
    private ProductDTO mapToDTO(Product product) {
        ProductDTO dto = new ProductDTO();
        dto.setId(product.getId());
        dto.setSku(product.getSku());
        dto.setName(product.getName());
        dto.setDescription(product.getDescription());
        dto.setPrice(product.getPrice());
        dto.setCompareAtPrice(product.getCompareAtPrice());
        dto.setCategoryId(product.getCategory() != null ? product.getCategory().getId() : null);
        dto.setCategoryName(product.getCategory() != null ? product.getCategory().getName() : null);
        dto.setQuantity(product.getQuantity());
        dto.setIsActive(product.getIsActive());
        dto.setIsFeatured(product.getIsFeatured());
        dto.setImages(product.getImages());
        dto.setTags(product.getTags());
        dto.setRating(product.getRating());
        dto.setReviewCount(product.getReviewCount());
        dto.setBrand(product.getBrand());
        dto.setCreatedAt(product.getCreatedAt());
        return dto;
    }
    
    private void mapFromDTO(ProductDTO dto, Product product) {
        product.setSku(dto.getSku());
        product.setName(dto.getName());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setCompareAtPrice(dto.getCompareAtPrice());
        
        if (dto.getCategoryId() != null) {
            Category category = categoryRepository.findById(dto.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("Category not found"));
            product.setCategory(category);
        }
        
        product.setQuantity(dto.getQuantity());
        product.setIsActive(dto.getIsActive());
        product.setIsFeatured(dto.getIsFeatured());
        product.setImages(dto.getImages());
        product.setTags(dto.getTags());
        product.setBrand(dto.getBrand());
    }
}
