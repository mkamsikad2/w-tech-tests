#!/bin/bash
yum update -y
yum install -y httpd

systemctl start httpd
systemctl enable httpd

# Create custom index page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<body>

<h1>Hello World</h1>
<p>Welcome to my world</p>

</body>
</html>
EOF

# Set proper permissions
chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html

# Restart Apache
systemctl restart httpd