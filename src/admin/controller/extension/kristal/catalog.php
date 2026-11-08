<?php
/**
 * Адмінка товару (фіча 005): вкладка «Оренда» і видимі «Атрибути» / «Знижки» — без правки шаблону ядра.
 *
 * Події (міграція 0006_kristal_product_rental):
 *   admin/view/catalog/product_form/after              → form()    вставити вкладки в HTML форми
 *   admin/model/catalog/product/{add,edit}Product/after → save()    зберегти kristal_rental[...] з форми
 *   admin/model/catalog/product/copyProduct/after      → copy()    скопіювати умови оренди
 *   admin/model/catalog/product/deleteProduct/after    → delete()  прибрати рядок
 * Панелі «Атрибути» й «Знижки» у формі ядра є, приховані лише посилання на них (правка часів sauco).
 */
class ControllerExtensionKristalCatalog extends Controller {
	public function form(&$route, &$data, &$output) {
		$tab_marker = '<li><a href="#tab-special" data-toggle="tab">';
		$pane_marker = '<div class="tab-pane" id="tab-special">';

		if (!is_string($output) || strpos($output, $tab_marker) === false || strpos($output, $pane_marker) === false) {
			$this->log->write('kristal_catalog: не знайдено вкладки форми товару — вкладку «Оренда» не додано');
			return null;
		}

		$lang = $this->load->language('extension/kristal/catalog');
		$this->load->model('extension/kristal/catalog');

		$product_id = isset($this->request->get['product_id']) ? (int)$this->request->get['product_id'] : 0;

		if ($this->request->server['REQUEST_METHOD'] === 'POST' && isset($this->request->post['kristal_rental'])) {
			$rental = \Kristal\Rental::normalize(array_merge(array('unit' => '', 'deposit' => 0, 'breakage_price' => 0, 'washing_included' => 0, 'is_hit' => 0), (array)$this->request->post['kristal_rental']));
		} else {
			$rental = $product_id ? $this->model_extension_kristal_catalog->getRental($product_id) : \Kristal\Rental::normalize(null);
		}

		$e = function ($s) {
			return htmlspecialchars((string)$s, ENT_QUOTES, 'UTF-8');
		};

		// Посилання на вкладки
		$tabs = '';

		// Лише якщо посилання ще немає (у шаблоні ядра вони закоментовані; після повернення шаблону до 3.0.4.1 — будуть)
		if (strpos($output, 'href="#tab-attribute"') === false) {
			$tabs .= '<li><a href="#tab-attribute" data-toggle="tab">' . $e(isset($data['tab_attribute']) ? $data['tab_attribute'] : 'Attribute') . '</a></li>';
		}

		if (strpos($output, 'href="#tab-discount"') === false) {
			$tabs .= '<li><a href="#tab-discount" data-toggle="tab">' . $e(isset($data['tab_discount']) ? $data['tab_discount'] : 'Discount') . '</a></li>';
		}

		$tabs .= '<li><a href="#tab-kristal-rental" data-toggle="tab">' . $e($lang['kc_tab']) . '</a></li>';

		// Панель «Оренда»
		$options = '';

		foreach (array_keys(\Kristal\Rental::units()) as $code) {
			$options .= '<option value="' . $e($code) . '"' . ($rental['unit'] === $code ? ' selected' : '') . '>' . $e($lang['kc_unit_' . $code]) . '</option>';
		}

		$number = function ($value) {
			return rtrim(rtrim(number_format((float)$value, 2, '.', ''), '0'), '.');
		};

		$pane = '<div class="tab-pane" id="tab-kristal-rental">'
			. '<p class="help-block">' . $e($lang['kc_note']) . '</p>'
			. '<div class="form-group"><label class="col-sm-2 control-label" for="input-kristal-unit"><span data-toggle="tooltip" title="' . $e($lang['kc_unit_help']) . '">' . $e($lang['kc_unit']) . '</span></label>'
			. '<div class="col-sm-10"><select name="kristal_rental[unit]" id="input-kristal-unit" class="form-control">' . $options . '</select></div></div>'
			. '<div class="form-group"><label class="col-sm-2 control-label" for="input-kristal-deposit"><span data-toggle="tooltip" title="' . $e($lang['kc_deposit_help']) . '">' . $e($lang['kc_deposit']) . '</span></label>'
			. '<div class="col-sm-10"><input type="number" min="0" step="0.01" name="kristal_rental[deposit]" value="' . $e($number($rental['deposit'])) . '" id="input-kristal-deposit" class="form-control"></div></div>'
			. '<div class="form-group"><label class="col-sm-2 control-label" for="input-kristal-breakage"><span data-toggle="tooltip" title="' . $e($lang['kc_breakage_help']) . '">' . $e($lang['kc_breakage']) . '</span></label>'
			. '<div class="col-sm-10"><input type="number" min="0" step="0.01" name="kristal_rental[breakage_price]" value="' . $e($number($rental['breakage_price'])) . '" id="input-kristal-breakage" class="form-control"></div></div>'
			. '<div class="form-group"><label class="col-sm-2 control-label" for="input-kristal-washing">' . $e($lang['kc_washing']) . '</label>'
			. '<div class="col-sm-10"><div class="checkbox"><label><input type="hidden" name="kristal_rental[washing_included]" value="0"><input type="checkbox" name="kristal_rental[washing_included]" value="1" id="input-kristal-washing"' . ($rental['washing_included'] ? ' checked' : '') . '></label></div></div></div>'
			. '<div class="form-group"><label class="col-sm-2 control-label" for="input-kristal-hit">' . $e($lang['kc_hit']) . '</label>'
			. '<div class="col-sm-10"><div class="checkbox"><label><input type="hidden" name="kristal_rental[is_hit]" value="0"><input type="checkbox" name="kristal_rental[is_hit]" value="1" id="input-kristal-hit"' . ($rental['is_hit'] ? ' checked' : '') . '></label></div></div></div>'
			. '</div>';

		$output = str_replace($tab_marker, $tabs . $tab_marker, $output);
		$output = str_replace($pane_marker, $pane . $pane_marker, $output);

		return null;
	}

	/** addProduct/after: $output = новий product_id; editProduct/after: $args[0] = product_id */
	public function save(&$route, &$args, &$output) {
		if (!isset($this->request->post['kristal_rental']) || !is_array($this->request->post['kristal_rental'])) {
			return null;
		}

		$product_id = (strpos($route, 'addProduct') !== false) ? (int)$output : (int)$args[0];

		if ($product_id > 0) {
			$this->load->model('extension/kristal/catalog');
			$this->model_extension_kristal_catalog->saveRental($product_id, $this->request->post['kristal_rental']);
			\Kristal\Cache_key::flush($this->cache);
		}

		return null;
	}

	public function copy(&$route, &$args, &$output) {
		$this->load->model('extension/kristal/catalog');
		$this->model_extension_kristal_catalog->copyRental((int)$args[0]);

		return null;
	}

	public function delete(&$route, &$args, &$output) {
		$this->load->model('extension/kristal/catalog');
		$this->model_extension_kristal_catalog->deleteRental((int)$args[0]);
		\Kristal\Cache_key::flush($this->cache);

		return null;
	}
}
