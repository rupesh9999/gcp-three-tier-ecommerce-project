package com.ecommerce.productservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductDTO {
    private Long id;
    private String sku;
    private String name;
    private String description;
    private BigDecimal price;
    private BigDecimal compareAtPrice;
    private Long categoryId;
    private String categoryName;
    private Integer quantity;
    private Boolean isActive;
    private Boolean isFeatured;
    private Set<String> images;
    private Set<String> tags;
    private Double rating;
    private Integer reviewCount;
    private String brand;
    private LocalDateTime createdAt;
}
