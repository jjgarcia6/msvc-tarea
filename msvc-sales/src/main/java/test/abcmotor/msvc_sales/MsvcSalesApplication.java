package test.abcmotor.msvc_sales;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
public class MsvcSalesApplication {

	public static void main(String[] args) {
		SpringApplication.run(MsvcSalesApplication.class, args);
	}

}
