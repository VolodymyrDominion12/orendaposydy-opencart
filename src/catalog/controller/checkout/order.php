<?php
class ControllerCheckoutOrder extends Controller {

    private $error = array();

    public function index() {

        $this->load->language('checkout/order');

        $this->load->model('setting/extension');

        $this->document->setTitle($this->language->get('heading_title'));

        $products = $this->cart();
        if($products){
            $data = $products;
        }

        $data['breadcrumbs'] = array();

        $data['breadcrumbs'][] = array(
            'href' => $this->url->link('common/home'),
            'text' => $this->language->get('text_home')
        );

        $data['breadcrumbs'][] = array(
            'href' => $this->url->link('checkout/order'),
            'text' => $this->language->get('heading_title')
        );

        $data['action'] = $this->url->link('checkout/order', '', true);

        $data['content_bottom'] = $this->load->controller('common/content_bottom');
        $data['footer'] = $this->load->controller('common/footer');
        $data['header'] = $this->load->controller('common/header');

        if (($this->request->server['REQUEST_METHOD'] == 'POST') && $this->validate()) {

            if (isset($this->request->post['name'])) {
                $data['name'] = $this->request->post['name'];
            }

            if (isset($this->request->post['phone'])) {
                $data['telephone'] = $this->request->post['phone'];
            }

            if (isset($this->request->post['address'])) {
                $data['address'] = $this->request->post['address'];
            }

            $this->confirm();
        }

        $data['shipping_free_status'] = $this->config->get('shipping_free_status');

        $data['shipping_free_total'] = $this->config->get('shipping_free_total');

        $data['currency'] = $this->session->data['currency'] ? $this->currency->getSymbolRight($this->session->data['currency']) : '';

        if (isset($this->error['name'])) {
            $data['error_name'] = $this->error['name'];
        } else {
            $data['error_name'] = '';
        }

        if (isset($this->error['phone'])) {
            $data['error_phone'] = $this->error['phone'];
        } else {
            $data['error_phone'] = '';
        }

        $this->response->setOutput($this->load->view('checkout/order', $data));
    }


    public function cart(){

        if ($this->cart->hasProducts()) {

            $this->load->model('tool/image');

            $data['products'] = array();

            $products = $this->cart->getProducts();

            foreach ($products as $product) {
                $product_total = 0;

                foreach ($products as $product_2) {
                    if ($product_2['product_id'] == $product['product_id']) {
                        $product_total += $product_2['quantity'];
                    }
                }

                if ($product['image']) {
                    $image = $this->model_tool_image->resize($product['image'], $this->config->get('theme_' . $this->config->get('config_theme') . '_image_cart_width'), $this->config->get('theme_' . $this->config->get('config_theme') . '_image_cart_height'));
                } else {
                    $image = '';
                }

                $option_data = array();

                // Display prices
                if ($this->customer->isLogged() || !$this->config->get('config_customer_price')) {
                    $unit_price = $this->tax->calculate($product['price'], $product['tax_class_id'], $this->config->get('config_tax'));
                    $price = $this->currency->format($unit_price, $this->session->data['currency']);
                    $js_price = $unit_price;
                    $total = $this->currency->format($unit_price * $product['quantity'], $this->session->data['currency']);
                } else {
                    $price = false;
                    $total = false;
                    $js_price = false;
                }

                $data['products'][] = array(
                    'cart_id'   => $product['cart_id'],
                    'product_id'=> $product['product_id'],
                    'thumb'     => $image,
                    'name'      => $product['name'],
                    'model'     => $product['model'],
                    'option'    => $option_data,
                    'quantity'  => $product['quantity'],
                    'stock'     => $product['stock'] ? true : !(!$this->config->get('config_stock_checkout') || $this->config->get('config_stock_warning')),
                    'price'     => $price,
                    'js_price'  => $js_price,
                    'total'     => $total,
                    'href'      => $this->url->link('product/product', 'product_id=' . $product['product_id'])
                );
            }

            // Totals
            $this->load->model('setting/extension');

            $totals = array();
            $total = 0;

            // Because __call can not keep var references so we put them into an array.
            $total_data = array(
                'totals' => &$totals,
                'total'  => &$total
            );


            // Display prices
            if ($this->customer->isLogged() || !$this->config->get('config_customer_price')) {
                $sort_order = array();

                $results = $this->model_setting_extension->getExtensions('total');

                foreach ($results as $key => $value) {
                    $sort_order[$key] = $this->config->get('total_' . $value['code'] . '_sort_order');
                }

                array_multisort($sort_order, SORT_ASC, $results);

                foreach ($results as $result) {
                    if ($this->config->get('total_' . $result['code'] . '_status')) {
                        $this->load->model('extension/total/' . $result['code']);

                        // We have to put the totals in an array so that they pass by reference.
                        $this->{'model_extension_total_' . $result['code']}->getTotal($total_data);
                    }
                }

                $sort_order = array();

                foreach ($totals as $key => $value) {
                    $sort_order[$key] = $value['sort_order'];
                }

                array_multisort($sort_order, SORT_ASC, $totals);
            }

            $currency = $this->session->data['currency'] ? $this->currency->getSymbolRight($this->session->data['currency']) : '';

            $data['cart_total_text'] = sprintf($this->language->get('text_sum'), $this->cart->countProducts());

            $data['cart_sum_text'] = sprintf($this->language->get('text_total_sum'), $total, $currency);

            $data['total'] = $total;

            $data['totals'] = array();

            foreach ($totals as $total) {
                $data['totals'][] = array(
                    'title' => $total['title'],
                    'text'  => $this->currency->format($total['value'], $this->session->data['currency'])
                );
            }
            return $data;
        } else {
            return 0;
        }
    }

    public function getTotal(){
        $json['total'] = $this->cart->getTotal();
        $json['qty'] = $this->cart->countProducts();

        $this->response->addHeader('Content-Type: application/json');
        $this->response->setOutput(json_encode($json));
    }


    public function confirm(){
        $this->load->model('checkout/simple_order');

        $products = $this->cart();

        if(empty($products)){
            $this->response->redirect($this->url->link('checkout/error'));
        }

        if(isset($this->request->post['payment_method'])){
            $payment_method = $this->request->post['payment_method'];
        }else{
            $payment_method = '';
        }

        if(isset($this->request->post['shipping_method'])){
            $shipping_method = $this->request->post['shipping_method'];
        }else{
            $shipping_method = '';
        }

        if(isset($this->request->post['name'])){
            $name = $this->request->post['name'];
        }else{
            $name = '';
        }

        if(isset($this->request->post['phone'])){
            $telephone = $this->request->post['phone'];
        }else{
            $telephone = '';
        }

        if(isset($this->request->post['address'])){
            $comment = $this->request->post['address'];
        }else{
            $comment = '';
        }

        $total = $products['total'];

//        if($shipping_method == 'flat.flat'){
//            $shipping = $this->config->get('shipping_flat_cost');
//            $total += $shipping;
//        }

        $order_data['invoice_prefix'] = $this->config->get('config_invoice_prefix');
        $order_data['store_id'] = $this->config->get('config_store_id');
        $order_data['store_name'] = $this->config->get('config_name');
        $order_data['customer_id'] = 0;
        $order_data['customer_group_id'] = 1;
        $order_data['firstname'] = $name;
        $order_data['lastname'] = $name;
        $order_data['email'] = '';
        $order_data['telephone'] = $telephone;
        $order_data['custom_field'] = [];
        $order_data['payment_firstname'] = $name;
        $order_data['payment_lastname'] = $name;
        $order_data['payment_company'] = $name;
        $order_data['payment_address_1'] = $name;
        $order_data['payment_address_2'] = $name;
        $order_data['payment_city'] = $name;
        $order_data['payment_postcode'] = '';
        $order_data['payment_country'] = '';
        $order_data['payment_country_id'] = 220;
        $order_data['payment_zone'] = '';
        $order_data['payment_zone_id'] = '';
        $order_data['payment_address_format'] = '';
        $order_data['payment_custom_field'] = [];
        $order_data['payment_method'] = $payment_method;
        $order_data['payment_code'] = $payment_method;
        $order_data['shipping_firstname'] = $name;
        $order_data['shipping_lastname'] = $name;
        $order_data['shipping_company'] = $name;
        $order_data['shipping_address_1'] = $name;
        $order_data['shipping_address_2'] = $name;
        $order_data['shipping_city'] = $name;
        $order_data['shipping_postcode'] = '';
        $order_data['shipping_country'] = '';
        $order_data['shipping_country_id'] = 220;
        $order_data['shipping_zone'] = '';
        $order_data['shipping_zone_id'] = '';
        $order_data['shipping_address_format'] = '';
        $order_data['shipping_custom_field'] = [];
        $order_data['shipping_method'] = $shipping_method;
        $order_data['shipping_code'] = $shipping_method;
        $order_data['comment'] = $comment;
        $order_data['total'] = $total;
        $order_data['affiliate_id'] = 0;
        $order_data['commission'] = 0.0;
        $order_data['marketing_id'] =  0;
        $order_data['tracking'] = '';
        $order_data['language_id'] =  $this->config->get('config_language_id');
        $order_data['currency_id'] = $this->currency->getId($this->session->data['currency']);
        $order_data['currency_code'] = $this->session->data['currency'];
        $order_data['currency_value'] =  $this->currency->getValue($this->session->data['currency']);
        $order_data['ip'] =  $this->request->server['REMOTE_ADDR'];

        if($products['totals']){
            foreach ($products['totals'] as $total) {
                $order_data['totals'][] = array(
                    'title' =>  $total['title'],
                    'value' =>  $total['text'],
                    'code'  =>  'sub_total',
                    'sort_order'  =>  '0',
                );
                break;
            }
        }

        if (!empty($this->request->server['HTTP_X_FORWARDED_FOR'])) {
            $order_data['forwarded_ip'] = $this->request->server['HTTP_X_FORWARDED_FOR'];
        } elseif (!empty($this->request->server['HTTP_CLIENT_IP'])) {
            $order_data['forwarded_ip'] = $this->request->server['HTTP_CLIENT_IP'];
        } else {
            $order_data['forwarded_ip'] = '';
        }

        if (isset($this->request->server['HTTP_USER_AGENT'])) {
            $order_data['user_agent'] = $this->request->server['HTTP_USER_AGENT'];
        } else {
            $order_data['user_agent'] = '';
        }

        if (isset($this->request->server['HTTP_ACCEPT_LANGUAGE'])) {
            $order_data['accept_language'] = $this->request->server['HTTP_ACCEPT_LANGUAGE'];
        } else {
            $order_data['accept_language'] = '';
        }

        if ($order_data['store_id']) {
            $order_data['store_url'] = $this->config->get('config_url');
        } else {
            if ($this->request->server['HTTPS']) {
                $order_data['store_url'] = HTTPS_SERVER;
            } else {
                $order_data['store_url'] = HTTP_SERVER;
            }
        }

        $order_data['products'] = array();

        foreach ($this->cart->getProducts() as $product) {
            $option_data = array();

            foreach ($product['option'] as $option) {
                $option_data[] = array(
                    'product_option_id'       => $option['product_option_id'],
                    'product_option_value_id' => $option['product_option_value_id'],
                    'option_id'               => $option['option_id'],
                    'option_value_id'         => $option['option_value_id'],
                    'name'                    => $option['name'],
                    'value'                   => $option['value'],
                    'type'                    => $option['type']
                );
            }

            $order_data['products'][] = array(
                'product_id' => $product['product_id'],
                'name'       => $product['name'],
                'model'      => $product['model'],
                'option'     => $option_data,
                'download'   => $product['download'],
                'quantity'   => $product['quantity'],
                'subtract'   => $product['subtract'],
                'price'      => $product['price'],
                'total'      => $product['total'],
                'tax'        => $this->tax->getTax($product['price'], $product['tax_class_id']),
                'reward'     => $product['reward']
            );
        }

        $this->session->data['order_id'] = $this->model_checkout_simple_order->addOrder($order_data);

        $set_from = 'mail@' . $this->request->server['SERVER_NAME'];

        $this->load->language('checkout/order');
        $order_data['text_product'] = $this->language->get('text_product');
        $order_data['text_quantity'] = $this->language->get('text_quantity');
        $order_data['text_price'] = $this->language->get('text_price');
        $order_data['text_total'] = $this->language->get('text_total');

        $mail = new Mail($this->config->get('config_mail_engine'));
        $mail->parameter = $this->config->get('config_mail_parameter');
        $mail->smtp_hostname = $this->config->get('config_mail_smtp_hostname');
        $mail->smtp_username = $this->config->get('config_mail_smtp_username');
        $mail->smtp_password = html_entity_decode($this->config->get('config_mail_smtp_password'), ENT_QUOTES, 'UTF-8');
        $mail->smtp_port = $this->config->get('config_mail_smtp_port');
        $mail->smtp_timeout = $this->config->get('config_mail_smtp_timeout');

        $mail->setTo($this->config->get('config_email'));
        $mail->setFrom($set_from);
        $mail->setSender(html_entity_decode($this->config->get('config_name'), ENT_QUOTES, 'UTF-8'));
        $mail->setSubject(html_entity_decode(sprintf($this->language->get('text_subject'), $this->config->get('config_name'), '', ENT_QUOTES, 'UTF-8')));
        $mail->setHtml($this->load->view('mail/order', $order_data));
        $mail->send();
        
        if($this->config->get('module_notifications_in_telegram_status')) {
	$this->load->model('extension/module/notifications_in_telegram');
	$this->model_extension_module_notifications_in_telegram->OrderNotification($order_data);
}
        

        if($payment_method == 'oplata'){
            $data['payment'] = $this->load->controller('extension/payment/oplata');
            $this->response->setOutput($this->load->view('checkout/foldy', $data));
        } else {
            $this->response->redirect($this->url->link('checkout/success'));
        }

    }

    public function shipping() {
        $this->load->language('checkout/checkout');

        // Shipping Methods
        $method_data = array();

        $this->load->model('setting/extension');

        $results = $this->model_setting_extension->getExtensions('shipping');


        foreach ($results as $result) {
            if ($this->config->get('shipping_' . $result['code'] . '_status')) {
                $this->load->model('extension/shipping/' . $result['code']);

                $quote = $this->{'model_extension_shipping_' . $result['code']}->getQuote();

                if ($quote) {
                    $method_data[$result['code']] = array(
                        'title'      => $quote['title'],
                        'quote'      => $quote['quote'],
                        'cost'       => $quote['quote'][$result['code']]['cost'] ? $this->currency->format($quote['quote'][$result['code']]['cost'], $this->session->data['currency']) : 0,
                        'sort_order' => $quote['sort_order'],
                        'error'      => $quote['error']
                    );
                }
            }
        }

        $sort_order = array();

        foreach ($method_data as $key => $value) {
            $sort_order[$key] = $value['sort_order'];
        }

        array_multisort($sort_order, SORT_ASC, $method_data);

        $this->session->data['shipping_methods'] = $method_data;

        if (isset($this->request->post['type'])) {

            //Если передают тип через ajax
            if($this->request->post['type'] !== ''){

                $method = strstr($this->request->post['type'],'.', true);

                //Проверяем доступно ли то что передают если нет то первый в списке отмечаем
                if(isset($method_data[$method])){
                    $this->session->data['shipping_method']['code'] = $this->request->post['type'];
                    $this->session->data['shipping_method']['title'] = $method_data[$method]['title'];
                    $this->session->data['shipping_method']['cost'] = $method_data[$method]['quote'][$method]['cost'];
                } else {
                    foreach ($method_data as $key=>$method_datum) {
                        $this->session->data['shipping_method']['code'] = $method_datum['quote'][$key]['code'];
                        $this->session->data['shipping_method']['title'] = $method_datum['title'];
                        $this->session->data['shipping_method']['cost'] = $method_datum['quote'][$key]['cost'];
                        break;
                    }
                }
            } else {
               if(empty($this->session->data['shipping_method'])){
                   foreach ($method_data as $key=>$method_datum) {
                       $this->session->data['shipping_method']['code'] = $method_datum['quote'][$key]['code'];
                       $this->session->data['shipping_method']['title'] = $method_datum['title'];
                       $this->session->data['shipping_method']['cost'] = $method_datum['quote'][$key]['cost'];
                       break;
                   }
               }
            }
        }
        else {
            foreach ($method_data as $key=>$method_datum) {
                $this->session->data['shipping_method']['code'] = $method_datum['quote'][$key]['code'];
                $this->session->data['shipping_method']['title'] = $method_datum['title'];
                $this->session->data['shipping_method']['cost'] = $method_datum['quote'][$key]['cost'];
                break;
            }
        }

        if (empty($this->session->data['shipping_methods'])) {
            $data['shipping_status'] = 0;
        } else {
            $data['shipping_status'] = 1;
        }

        if (isset($this->session->data['shipping_methods'])) {
            $data['shipping_methods'] = $this->session->data['shipping_methods'];
        } else {
            $data['shipping_methods'] = array();
        }

        if (isset($this->session->data['shipping_method']['code'])) {
            $data['code'] = $this->session->data['shipping_method']['code'];
        } else {
            $data['code'] = '';
        }

        if (isset($this->session->data['comment'])) {
            $data['comment'] = $this->session->data['comment'];
        } else {
            $data['comment'] = '';
        }

        $currency = $this->session->data['currency'] ? $this->currency->getSymbolRight($this->session->data['currency']) : '';

        $data['shipping_free_status'] = $this->config->get('shipping_free_status');

        $data['shipping_free_total'] = sprintf($this->language->get('text_shipping_free'), $this->config->get('shipping_free_total'), $currency);

        $this->response->setOutput($this->load->view('checkout/shipping_method', $data));
    }

    public function payment() {
        $this->load->language('checkout/checkout');

        // Totals
        $totals = array();
        $taxes = $this->cart->getTaxes();
        $total = 0;

        // Because __call can not keep var references so we put them into an array.
        $total_data = array(
            'totals' => &$totals,
            'taxes'  => &$taxes,
            'total'  => &$total
        );

        $this->load->model('setting/extension');

        $sort_order = array();

        $results = $this->model_setting_extension->getExtensions('total');

        foreach ($results as $key => $value) {
            $sort_order[$key] = $this->config->get('total_' . $value['code'] . '_sort_order');
        }

        array_multisort($sort_order, SORT_ASC, $results);

        foreach ($results as $result) {
            if ($this->config->get('total_' . $result['code'] . '_status')) {
                $this->load->model('extension/total/' . $result['code']);

                // We have to put the totals in an array so that they pass by reference.
                $this->{'model_extension_total_' . $result['code']}->getTotal($total_data);
            }
        }

        // Payment Methods
        $method_data = array();

        $this->load->model('setting/extension');

        $results = $this->model_setting_extension->getExtensions('payment');

        $recurring = $this->cart->hasRecurringProducts();

        foreach ($results as $result) {
            if ($this->config->get('payment_' . $result['code'] . '_status')) {
                $this->load->model('extension/payment/' . $result['code']);

                $method = $this->{'model_extension_payment_' . $result['code']}->getMethod($total);
                if ($method) {
                    if ($recurring) {
                        if (property_exists($this->{'model_extension_payment_' . $result['code']}, 'recurringPayments') && $this->{'model_extension_payment_' . $result['code']}->recurringPayments()) {
                            $method_data[$result['code']] = $method;
                        }
                    } else {
                        $method_data[$result['code']] = $method;
                    }
                }
            }
        }

        $sort_order = array();

        foreach ($method_data as $key => $value) {
            $sort_order[$key] = $value['sort_order'];
        }

        array_multisort($sort_order, SORT_ASC, $method_data);

        $this->session->data['payment_methods'] = $method_data;

        if (isset($this->request->post['type'])) {

            if($this->request->post['type'] !== ''){

                $this->session->data['payment_method']['code'] = $this->request->post['type'];
            } else {
                if(empty($this->session->data['payment_method'])){
                    foreach ($method_data as $key=>$method_datum) {
                        $this->session->data['payment_method'][$key] = $method_datum['code'];
                        break;
                    }
                }
            }
        } else {
            foreach ($method_data as $key=>$method_datum) {
                $this->session->data['payment_method'][$key] = $method_datum['code'];
                break;
            }
        }

        if (empty($this->session->data['payment_methods'])) {
            $data['payment_status'] = 0;
        } else {
            $data['payment_status'] = 1;
        }

        if (isset($this->session->data['payment_methods'])) {
            $data['payment_methods'] = $this->session->data['payment_methods'];
        } else {
            $data['payment_methods'] = array();
        }

        if (isset($this->session->data['payment_method']['code'])) {
            $data['code'] = $this->session->data['payment_method']['code'];
        } else {
            $data['code'] = '';
        }

        if (isset($this->session->data['comment'])) {
            $data['comment'] = $this->session->data['comment'];
        } else {
            $data['comment'] = '';
        }

        $this->response->setOutput($this->load->view('checkout/payment_method', $data));
    }

    private function validate() {
        if ((utf8_strlen(trim($this->request->post['name'])) < 1) || (utf8_strlen(trim($this->request->post['name'])) > 32)) {
            $this->error['name'] = $this->language->get('error_name');
        }

        preg_match('/^(\s*)?(\+)?([- _():=+]?\d[- _():=+]?){9,14}(\s*)?$/',$this->request->post['phone'],$phone);

        if (empty($phone)) {
            $this->error['phone'] = $this->language->get('error_phone');
        }

        return !$this->error;
    }

}