#include <stdint.h>
#include <csr.h>
#include <soc.h>
#include <irq_vex.h>

// irq.c will define this
extern volatile uint16_t flag;

// Optional: if your generated csr.h provides TIMER0 EV pending
#ifdef CSR_TIMER0_EV_PENDING_ADDR
#define reg_timer0_ev_pending (*(volatile uint32_t*) CSR_TIMER0_EV_PENDING_ADDR)
#endif

void isr(void)
{
    unsigned int irqs = irq_pending();

    if (irqs & (1 << TIMER0_INTERRUPT)) {
        // ACK/CLEAR timer interrupt if pending register exists
        #ifdef CSR_TIMER0_EV_PENDING_ADDR
            reg_timer0_ev_pending = 1;
        #endif

        flag = 1;
        // Also mask it if you want single-shot behavior
        irq_setmask(irq_getmask() & ~(1 << TIMER0_INTERRUPT));
        return;
    }
}

