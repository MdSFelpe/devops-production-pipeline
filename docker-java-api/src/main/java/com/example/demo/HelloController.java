package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

	@GetMapping("/")
	public String home() {
		return "🚀 Docker + Java Spring Boot + PostgreSQL operando com sucesso!";
	}
}
