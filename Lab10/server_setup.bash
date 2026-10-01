sudo cp my_site /etc/nginx/sites-available/
cp my_site.html /var/www/html/my_site.html
sudo ln -s /etc/nginx/sites-available/my_site /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx