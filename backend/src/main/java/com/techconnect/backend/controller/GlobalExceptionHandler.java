package com.techconnect.backend.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(org.springframework.web.server.ResponseStatusException.class)
    public ResponseEntity<Map<String, String>> handleResponseStatus(org.springframework.web.server.ResponseStatusException ex) {
        String msg = ex.getReason() != null ? ex.getReason() : ex.getMessage();
        return ResponseEntity
                .status(ex.getStatusCode())
                .body(Map.of("message", msg, "error", msg));
    }

    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<Map<String, String>> handleRuntime(RuntimeException ex) {
        String msg = ex.getMessage() != null ? ex.getMessage() : "An error occurred";
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("message", msg, "error", msg));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<Map<String, String>> handleIllegalArg(IllegalArgumentException ex) {
        String msg = ex.getMessage() != null ? ex.getMessage() : "Invalid argument";
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("message", msg, "error", msg));
    }
}
