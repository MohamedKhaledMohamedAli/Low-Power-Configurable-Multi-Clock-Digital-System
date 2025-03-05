# Synchronizers

## Description
Collection of synchronizers to manage **Clock Domain Crossings**.

## Synchronization Modules
1. **RST_SYNC**
   - Synchronizes reset signals between domains
   
2. **DATA_SYNC**
   - Handles 8-bit bus synchronization
   - Generates enable pulses

3. **ASYNC_FIFO**
   - Parameterized width (default 8-bit)
   - Depth: 16 entries (default)
