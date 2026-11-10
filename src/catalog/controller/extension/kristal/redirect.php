<?php
class ControllerExtensionKristalRedirect extends Controller {
	public function check(&$route, &$data) {
		$req_uri = isset($this->request->server['REQUEST_URI']) ? $this->request->server['REQUEST_URI'] : '';
		$norm_path = \Kristal\Redirect::normalize($req_uri);

		$rules = \Kristal\Redirect::getRules($this->db, $this->cache);

		if (isset($rules[$norm_path])) {
			$rule = $rules[$norm_path];
			\Kristal\Redirect::recordHit($this->db, $rule['id']);

			$target = $rule['new_path'];
			if (strpos($target, 'http://') !== 0 && strpos($target, 'https://') !== 0) {
				$base = isset($this->request->server['HTTPS']) && (($this->request->server['HTTPS'] == 'on') || ($this->request->server['HTTPS'] == '1')) ? HTTPS_SERVER : HTTP_SERVER;
				$target = rtrim($base, '/') . '/' . ltrim($target, '/');
			}

			// Зберігаємо query string, якщо він був у запиті
			$query = parse_url($req_uri, PHP_URL_QUERY);
			if ($query) {
				$target .= (strpos($target, '?') !== false ? '&' : '?') . $query;
			}

			$code = $rule['code'] ? (int)$rule['code'] : 301;
			$this->response->redirect($target, $code);
			$this->response->output();
			exit();
		}

		// Якщо правила немає — фіксуємо в журналі 404
		$referer = isset($this->request->server['HTTP_REFERER']) ? $this->request->server['HTTP_REFERER'] : '';
		\Kristal\Redirect::log404($this->db, $norm_path, $referer);
	}
}
