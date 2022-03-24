#![no_std]
#![no_main]

use core::panic::PanicInfo;

mod vga_buffer;

/// This function is called on panic.
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

static HELLO: &[u8] = b"Hello World!";

// Run with
// 1. cargo bootimage
// 2. qemu-system-x86_64 -drive format=raw,file=target/x86_64-rust_os/debug/bootimage-rust_os.bin
#[no_mangle] // don't mangle the name of this function
pub extern "C" fn _start() -> ! {
    // this function is the entry point, since the linker looks for a function
    // named `_start` by default

    vga_buffer::print_something();


//    let vga_buffer = 0xb8000 as *mut u8;

//    for (i, &byte) in HELLO.iter().enumerate() {
//        unsafe {
//            *vga_buffer.offset(i as isize * 2) = byte;
//            *vga_buffer.offset(i as isize * 2 + 1) = 0xb;
//        }
//    }
    loop {}
}
