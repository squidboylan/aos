/* With minor changes, this start code was taken from:
 * https://github.com/bztsrc/raspi3-tutorial
 *
 * Thank you!
 */

.global _start

_start:
	/* Read Multiprocessor Affinity Register with special MRS instruction
	 * used to access system registers to identify what core we're running on.
	 * Reference: https://developer.arm.com/docs/ddi0500/g/system-control/aarch64-register-descriptions/multiprocessor-affinity-register
	 */
	mrs     x1, mpidr_el1

	/* Cortex-A53 is equipped with 4 cores (all of which are running), so
	 * we will want to park the other 3 while the primary core (core 0)
	 * performs set-up.
	 *
	 * This is a 64-bit register where the core identifier is in the last
	 * 2 bits (4 cores, only 2 bits needed to represent IDs up to 4). Mask
	 * them off. If the identifier is 0, then this is the primary core with
	 * which we'll perform set-up with.
	 */
	and     x1, x1, #0x3
	cbz     x1, begin_setup
wait_here:
	/* Otherwise, we'll park the core here and tell it to wait for an event.
	 * (presumably from us)
	 * Reference: https://developer.arm.com/docs/den0024/latest/the-a64-instruction-set/system-control-and-other-instructions/hint-instructions
	 */
	wfe
	b 	wait_here

begin_setup:
	/* Move the stack to grow down from where our code begins. */
	ldr     x1, =_start
	mov     sp, x1

	/* Load the bss (refer to linker script to see where these are) */
	ldr     x1, =__bss_start
	ldr     w2, =__bss_end
	subs    w2, w2, w1


clear_bss:
	/* Global variables live in the bss section, and therefore we must zero it
	 * out.
	 *
	 * We've stored the size of the bss in w2, so once this hits zero, we
	 * have cleared the entire section.
	 */
	cbz     w2, enter_kernel
	str     xzr, [x1], #8
	sub     w2, w2, #1
	cbnz    w2, clear_bss

enter_kernel:
	/* Enter C code... */
	bl      kmain
	/* ...we should never return here. */
	b	wait_here
