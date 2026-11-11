-- 301 зі старих коротких адрес категорій (були в старому sitemap, можуть бути в Google).
-- Ідемпотентно: INSERT IGNORE за унікальним old_path.
SET NAMES utf8mb4;

INSERT IGNORE INTO `{{PREFIX}}kristal_redirect` (`old_path`,`new_path`,`code`,`status`) VALUES
('/bilij-posud','/posud/tarilky',301,1),
('/stakani','/sklo-ta-kelykhy/sklianky',301,1),
('/supnici','/posud/supnytsi',301,1),
('/salatnici','/posud/salatnytsi',301,1),
('/videlka','/stolovi-prybory/vydelky',301,1),
('/lozhki','/stolovi-prybory/lozhky',301,1),
('/nozhi','/stolovi-prybory/nozhi',301,1),
('/ditichnij-kompleksu','/sklo-ta-kelykhy',301,1),
('/derev-yani-doshki','/ekoposud/dereviani-doshky',301,1),
('/inventar-ta-posud-z-plastiku','/ekoposud/inventar-z-plastyku',301,1),
('/m-yasni-stravi','/posud/tarilky',301,1),
('/ovochevi-salati','/stolovi-prybory',301,1);
