# Clock Domain Crossings

## Synchronization Modules
1. **RST_SYNC**
   - Synchronizes reset signals between domains
   
2. **DATA_SYNC**
   - Handles 8-bit bus synchronization
   - Generates enable pulses

3. **ASYNC_FIFO**
   - Parameterized width (default 8-bit)
   - Depth: 16 entries (default)
  
4. **PULSE_GEN**
   - Convert level signal from UART TX to a pulse signal for ASYNC_FIFO

5. **ClkDiv**
   - Adjusts the UART clock frequency to generate the required baud rate for UART communication.  
