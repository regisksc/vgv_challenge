
---

## Layers

1. **Presentation Layer**  
   - **Widgets/Pages**: The UI components and pages that users interact with.  
   - **Blocs/Cubits/Providers**: Manages state, business logic orchestration, and communication between UI and domain.

2. **Domain Layer**  
   - **Entities**: Core objects that represent essential business data objects ( `Coffee`).  
   - **Use Cases (definition)**: Encapsulate business logic such as fetching a random coffee image or saving a favorite locally. Transforms actions into architectural components, similar to *Command Design Pattern*

3. **Data Layer**  
   - **Use Cases (implementation)**: Implements the usecase definitions and integrates remaining components to make that action, input and output possible.- **Models**: Encapsulate comunication with external applications, such as `Hive` and the `Coffee Api`. Does encoding, decoding and mapping to/from entity.
   - **Data Sources (definition)**: Defines the two main forms of acquiring data for this particular software, and `HttpClient` and a `Storage` manager.  
   - **Adapters (implementation)**: Implements a generalistic interface to adapt calls to third party dependencies eg: `Dio` and `Hive`. Implements Data Sources  

---

## State Management

- **BLoC/Cubit (Recommended)**  
  - Each major feature or screen has its own BLoC/Cubit.  
  - Decouples UI from the underlying logic.  
  - Makes testing straightforward by allowing each block of logic to be tested independently.

---

## Flow

1. **Presentation** -> requests a **Use Case** .  
2. **Use Case** -> calls the **Data Source** interface.  
3. **Data Source Adapters** -> fetches data from either the **API** or **Local** storage.  
4. **Data** is returned up the chain to the **Presentation** layer, which updates the UI.

---

## Why This Architecture?

- **Clarity**: Encourages a clear separation between UI, domain logic, and data access.  
- **Testability**: Each layer can be tested independently, especially the domain layer.  
- **Scalability**: New features can be added by extending the architecture in their respective layers without breaking existing modules.

---

> For deeper insight into the core domain objects and logic, see [domain.md](./domain.md).
