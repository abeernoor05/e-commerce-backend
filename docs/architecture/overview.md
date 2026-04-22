# Architecture Overview

- auth-service: authentication and JWT
- product-service: catalog and stock
- order-service: order lifecycle and stock validation

## Communication
- Synchronous REST between services.
- Future improvement: event-driven messaging (Kafka/RabbitMQ).
