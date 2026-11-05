<?php
class ModelExtensionModuleNotificationsInTelegram extends Model {
	public function Send($text, $chat_id) {
		$ch = curl_init();
		curl_setopt_array(
			$ch,
			array(
				CURLOPT_URL => 'https://api.telegram.org/bot' . $this->config->get('module_notifications_in_telegram_bot_token') . '/sendMessage',
				CURLOPT_POST => TRUE,
				CURLOPT_RETURNTRANSFER => TRUE,
				CURLOPT_TIMEOUT => 10,
				CURLOPT_POSTFIELDS => array(
					'chat_id' => $chat_id,
					'text' => $text,
				),
			)
		);
		curl_exec($ch);
	}
    public function OrderNotification($data) {
		
		if(strpos($data['shipping_method'],'.') !== false){
			$_shipping = strstr($data['shipping_method'], '.', true);
		} else {
			$_shipping = $data['shipping_method'];
		}
		
		$this->load->model('extension/shipping/' . $_shipping);
		
		$shiping_method = $this->{'model_extension_shipping_' . $_shipping}->getQuote();

		if(strpos($data['payment_method'],'.') !== false){
			$_payment = strstr($data['payment_method'], '.', true);
		} else {
			$_payment = $data['payment_method'];
		}
		
		$this->load->model('extension/payment/' . $_payment);
		
		$payment = $this->{'model_extension_payment_' . $_payment}->getMethod(array('country_id'=>$data['payment_country_id'], 'zone_id'=>$data['payment_zone_id']), $data['total']);
		
		
        $text = $this->config->get('config_name')." - нове замовлення!";
		$text .= "\n\nІм'я: " .$data['firstname'];
		$text .= "\nТелефон: " .$data['telephone'];
		$text .= "\nСпосіб доставки: " .$shiping_method['title'];
		$text .= "\nСпосіб оплати: " .$payment['title'];
		$text .= "\n\nТовари :";
		foreach($data['products'] as $product) {
			$text .= "\n - ".$product['name']." : ".$this->currency->format($product['price'], $this->session->data['currency'])." x ".$product['quantity']." = ".$this->currency->format($product['total'], $this->session->data['currency']);
		}
		
		if($shiping_method["quote"][$_shipping]["cost"]>0) {
			$text .= "\n\nДоставка: " .$this->currency->format($shiping_method["quote"][$_shipping]["cost"], $this->session->data['currency']);
		}
		
		$text .= "\n\nРазом: " .$this->currency->format($data['total'], $this->session->data['currency']);
		$text .= "\n\nКоментар: " .$data['comment'];
		
		$chat_ids = array();
	   
	    $ci = str_replace(' ', '', $this->config->get('module_notifications_in_telegram_chat_id'));
	   
	    if(strpos($ci,',') !== false){
			$chat_ids = explode(',', $ci);
		} else {
			$chat_ids[] = $ci;
		}
		
		foreach($chat_ids as $chat_id) {		
			$this->Send($text, $chat_id);		
		}
    }
}