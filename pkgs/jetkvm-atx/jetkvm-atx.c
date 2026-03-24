/*
 * The reason for this firmware being here is that I need to remap the stock
 * pins to have different meanings, so that I can connect the front panel of my
 * chassis to the extension.
 *
 * The mappings are as follows:
 * LED_HDD -> LED_PWR
 * LED_PWR -> LED_HDD
 */

#include "hardware/gpio.h"
#include "hardware/uart.h"
#include "hardware/watchdog.h"
#include "pico/stdlib.h"
#include <stdio.h>
#include <string.h>

#define UART_ID uart0
#define BAUD_RATE 115200

#define UART_TX_PIN 16
#define UART_RX_PIN 17
#define BTN_RST_PIN 18
#define BTN_PWR_PIN 19
#define LED_HDD_PIN 21
#define LED_PWR_PIN 20

#define UART_BUF_SIZE 128
static char uart_buf[UART_BUF_SIZE];
static int uart_buf_pos = 0;

void on_uart_line(const char *line) {
  printf("UART LINE: %s\n", line);
  if (strcmp(line, "BTN_RST_ON\n") == 0) {
    gpio_put(BTN_RST_PIN, 1);
  } else if (strcmp(line, "BTN_RST_OFF\n") == 0) {
    gpio_put(BTN_RST_PIN, 0);
  } else if (strcmp(line, "BTN_PWR_ON\n") == 0) {
    gpio_put(BTN_PWR_PIN, 1);
  } else if (strcmp(line, "BTN_PWR_OFF\n") == 0) {
    gpio_put(BTN_PWR_PIN, 0);
  }
}

void on_uart_rx() {
  while (uart_is_readable(UART_ID)) {
    uint8_t ch = uart_getc(UART_ID);

    if (uart_buf_pos < UART_BUF_SIZE - 1) {
      uart_buf[uart_buf_pos++] = ch;
    }

    if (ch == '\n' || uart_buf_pos >= UART_BUF_SIZE - 1) {
      uart_buf[uart_buf_pos] = '\0';
      on_uart_line(uart_buf);
      uart_buf_pos = 0;
    }
  }
}

int main() {
  stdio_init_all();

  if (watchdog_caused_reboot()) {
    printf("Rebooted by Watchdog!\n");
  }

  watchdog_enable(8388, true);

  gpio_set_function(UART_TX_PIN, UART_FUNCSEL_NUM(UART_ID, UART_TX_PIN));
  gpio_set_function(UART_RX_PIN, UART_FUNCSEL_NUM(UART_ID, UART_RX_PIN));

  uart_init(UART_ID, BAUD_RATE);
  uart_set_hw_flow(UART_ID, false, false);
  uart_set_format(UART_ID, 8, 1, UART_PARITY_NONE);
  uart_set_fifo_enabled(UART_ID, true);
  int UART_IRQ = UART_ID == uart0 ? UART0_IRQ : UART1_IRQ;
  irq_set_exclusive_handler(UART_IRQ, on_uart_rx);
  irq_set_enabled(UART_IRQ, true);
  uart_set_irq_enables(UART_ID, true, false);

  gpio_init(BTN_RST_PIN);
  gpio_set_dir(BTN_RST_PIN, GPIO_OUT);
  gpio_put(BTN_RST_PIN, 0);

  gpio_init(BTN_PWR_PIN);
  gpio_set_dir(BTN_PWR_PIN, GPIO_OUT);
  gpio_put(BTN_PWR_PIN, 0);

  gpio_init(LED_HDD_PIN);
  gpio_pull_up(LED_HDD_PIN);
  gpio_set_dir(LED_HDD_PIN, GPIO_IN);

  gpio_init(LED_PWR_PIN);
  gpio_pull_up(LED_PWR_PIN);
  gpio_set_dir(LED_PWR_PIN, GPIO_IN);

  bool btn_rst_state = false;
  bool btn_pwr_state = false;
  bool led_hdd_state = false;
  bool led_pwr_state = false;
  uint64_t last_update_sent = 0;
  uint64_t last_watchdog_reset = 0;
  char message[6];
  while (true) {
    uint64_t now = time_us_64();

    bool new_led_hdd_state = gpio_get(LED_HDD_PIN);
    bool new_led_pwr_state = gpio_get(LED_PWR_PIN);
    bool new_btn_rst_state = gpio_get(BTN_RST_PIN);
    bool new_btn_pwr_state = gpio_get(BTN_PWR_PIN);

    bool states_changed = new_led_hdd_state != led_hdd_state ||
                          new_led_pwr_state != led_pwr_state ||
                          new_btn_rst_state != btn_rst_state ||
                          new_btn_pwr_state != btn_pwr_state;

    // if states changed or 1000ms passed since last update
    if (states_changed || (now - last_update_sent > 1000000)) {
      snprintf(message, 6, "%d%d%d%d\n", new_led_hdd_state, new_led_pwr_state,
               new_btn_rst_state, new_btn_pwr_state);
      uart_puts(UART_ID, message);
      last_update_sent = now;
      printf("Sent at %llu: %s", now, message);

      led_hdd_state = new_led_hdd_state;
      led_pwr_state = new_led_pwr_state;
      btn_rst_state = new_btn_rst_state;
      btn_pwr_state = new_btn_pwr_state;
    }

    if (now - last_watchdog_reset > 1000000) {
      watchdog_update();
      last_watchdog_reset = now;
    }

    sleep_ms(10);
  }
}
