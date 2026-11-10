<?php
/**
 * Безпека адмінки (фіча 017).
 *
 * Подія kristal_security_cookie (міграція 0012_kristal_security):
 *   admin/controller/* /before → cookie()   атрибути куки сесії (HttpOnly, Secure, SameSite) — \Kristal\Cookie
 * Кука вже виставлена system/framework.php ядра (session_autostart); кука та сама, що у вітрини
 * (ім'я й шлях однакові), тому атрибути теж однакові — інакше вони перемикались би між вітриною й адмінкою.
 * Один раз за запит, запитів до БД немає.
 */
class ControllerExtensionKristalSecurity extends Controller {
	private static $done = false;

	public function cookie(&$route, &$args) {
		if (!self::$done) {
			self::$done = true;

			\Kristal\Cookie::apply((string)$this->config->get('session_name'), \Kristal\Cookie::isHttps($this->request->server));
		}

		return null;
	}
}
