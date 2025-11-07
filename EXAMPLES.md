# Code Examples

Examples of sending emails from various programming languages using mini-SMTP-server.

## Table of Contents

- [Python](#python)
- [Node.js](#nodejs)
- [PHP](#php)
- [Java](#java)
- [C# / .NET](#c--net)
- [Go](#go)
- [Ruby](#ruby)

---

## Python

### Using smtplib (standard library)

```python
import smtplib
from email.message import EmailMessage

def send_email(to_address, subject, body):
    msg = EmailMessage()
    msg['Subject'] = subject
    msg['From'] = 'noreply@your-domain.com'
    msg['To'] = to_address
    msg.set_content(body)

    # Connect to mini-smtp-server
    with smtplib.SMTP('smtp', 25) as server:
        server.send_message(msg)

    print(f"Email sent to {to_address}")

# Usage
send_email(
    'recipient@example.com',
    'Test Email',
    'Hello from mini-smtp-server!'
)
```

### Using Django

```python
# settings.py
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp'
EMAIL_PORT = 25
EMAIL_USE_TLS = False
EMAIL_USE_SSL = False
DEFAULT_FROM_EMAIL = 'noreply@your-domain.com'

# In your views or tasks
from django.core.mail import send_mail

send_mail(
    'Subject here',
    'Here is the message.',
    'noreply@your-domain.com',
    ['recipient@example.com'],
    fail_silently=False,
)
```

### Using Flask-Mail

```python
from flask import Flask
from flask_mail import Mail, Message

app = Flask(__name__)
app.config['MAIL_SERVER'] = 'smtp'
app.config['MAIL_PORT'] = 25
app.config['MAIL_USE_TLS'] = False
app.config['MAIL_USE_SSL'] = False
app.config['MAIL_DEFAULT_SENDER'] = 'noreply@your-domain.com'

mail = Mail(app)

@app.route('/send')
def send_email():
    msg = Message(
        'Hello',
        recipients=['recipient@example.com']
    )
    msg.body = 'This is a test email from Flask'
    mail.send(msg)
    return 'Email sent!'
```

---

## Node.js

### Using Nodemailer

```javascript
const nodemailer = require('nodemailer');

// Create transporter
const transporter = nodemailer.createTransport({
  host: 'smtp',
  port: 25,
  secure: false, // no TLS for internal relay
  tls: {
    rejectUnauthorized: false
  }
});

// Send email
async function sendEmail() {
  try {
    const info = await transporter.sendMail({
      from: 'noreply@your-domain.com',
      to: 'recipient@example.com',
      subject: 'Test Email',
      text: 'Hello from mini-smtp-server!',
      html: '<p>Hello from <strong>mini-smtp-server</strong>!</p>'
    });

    console.log('Message sent: %s', info.messageId);
  } catch (error) {
    console.error('Error sending email:', error);
  }
}

sendEmail();
```

### Using EmailJS (for Node.js server-side)

```javascript
const email = require('emailjs');

const server = email.server.connect({
  host: 'smtp',
  port: 25,
  tls: false
});

server.send({
  from: 'noreply@your-domain.com',
  to: 'recipient@example.com',
  subject: 'Test Email',
  text: 'Hello from mini-smtp-server!'
}, (err, message) => {
  if (err) {
    console.error('Error:', err);
  } else {
    console.log('Email sent:', message);
  }
});
```

---

## PHP

### Using PHP mail() function

```php
<?php
// Configure PHP to use mini-smtp-server
ini_set('SMTP', 'smtp');
ini_set('smtp_port', 25);

$to = 'recipient@example.com';
$subject = 'Test Email';
$message = 'Hello from mini-smtp-server!';
$headers = 'From: noreply@your-domain.com' . "\r\n" .
           'Reply-To: noreply@your-domain.com' . "\r\n" .
           'X-Mailer: PHP/' . phpversion();

if (mail($to, $subject, $message, $headers)) {
    echo "Email sent successfully!";
} else {
    echo "Failed to send email.";
}
?>
```

### Using PHPMailer

```php
<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php';

$mail = new PHPMailer(true);

try {
    // Server settings
    $mail->isSMTP();
    $mail->Host       = 'smtp';
    $mail->SMTPAuth   = false;
    $mail->Port       = 25;

    // Recipients
    $mail->setFrom('noreply@your-domain.com', 'Your App');
    $mail->addAddress('recipient@example.com', 'Recipient Name');

    // Content
    $mail->isHTML(true);
    $mail->Subject = 'Test Email';
    $mail->Body    = '<p>Hello from <strong>mini-smtp-server</strong>!</p>';
    $mail->AltBody = 'Hello from mini-smtp-server!';

    $mail->send();
    echo 'Message has been sent';
} catch (Exception $e) {
    echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
}
?>
```

### Using Laravel

```php
// config/mail.php
'mailers' => [
    'smtp' => [
        'transport' => 'smtp',
        'host' => env('MAIL_HOST', 'smtp'),
        'port' => env('MAIL_PORT', 25),
        'encryption' => null,
        'username' => null,
        'password' => null,
    ],
],

'from' => [
    'address' => env('MAIL_FROM_ADDRESS', 'noreply@your-domain.com'),
    'name' => env('MAIL_FROM_NAME', 'Your App'),
],

// In your controller or job
use Illuminate\Support\Facades\Mail;

Mail::raw('Hello from mini-smtp-server!', function ($message) {
    $message->to('recipient@example.com')
            ->subject('Test Email');
});
```

---

## Java

### Using JavaMail API

```java
import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;

public class EmailSender {
    public static void sendEmail(String to, String subject, String body) {
        // Configure SMTP
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp");
        props.put("mail.smtp.port", "25");
        props.put("mail.smtp.auth", "false");

        // Create session
        Session session = Session.getInstance(props);

        try {
            // Create message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress("noreply@your-domain.com"));
            message.setRecipients(
                Message.RecipientType.TO,
                InternetAddress.parse(to)
            );
            message.setSubject(subject);
            message.setText(body);

            // Send message
            Transport.send(message);

            System.out.println("Email sent successfully!");

        } catch (MessagingException e) {
            throw new RuntimeException(e);
        }
    }

    public static void main(String[] args) {
        sendEmail(
            "recipient@example.com",
            "Test Email",
            "Hello from mini-smtp-server!"
        );
    }
}
```

### Using Spring Boot

```java
// application.properties
spring.mail.host=smtp
spring.mail.port=25
spring.mail.properties.mail.smtp.auth=false
spring.mail.properties.mail.smtp.starttls.enable=false

// EmailService.java
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    public void sendEmail(String to, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("noreply@your-domain.com");
        message.setTo(to);
        message.setSubject(subject);
        message.setText(text);

        mailSender.send(message);
    }
}
```

---

## C# / .NET

### Using System.Net.Mail

```csharp
using System;
using System.Net;
using System.Net.Mail;

class EmailSender
{
    static void SendEmail(string to, string subject, string body)
    {
        using (var client = new SmtpClient("smtp", 25))
        {
            client.EnableSsl = false;
            client.Credentials = null;

            var message = new MailMessage(
                from: "noreply@your-domain.com",
                to: to,
                subject: subject,
                body: body
            );

            client.Send(message);
            Console.WriteLine("Email sent successfully!");
        }
    }

    static void Main()
    {
        SendEmail(
            "recipient@example.com",
            "Test Email",
            "Hello from mini-smtp-server!"
        );
    }
}
```

### Using MailKit (recommended)

```csharp
using MailKit.Net.Smtp;
using MimeKit;

class EmailSender
{
    static void SendEmail(string to, string subject, string body)
    {
        var message = new MimeMessage();
        message.From.Add(new MailboxAddress("Your App", "noreply@your-domain.com"));
        message.To.Add(new MailboxAddress("", to));
        message.Subject = subject;
        message.Body = new TextPart("plain") { Text = body };

        using (var client = new SmtpClient())
        {
            client.Connect("smtp", 25, false);
            client.Send(message);
            client.Disconnect(true);
        }
    }
}
```

---

## Go

### Using net/smtp (standard library)

```go
package main

import (
    "fmt"
    "net/smtp"
)

func sendEmail(to string, subject string, body string) error {
    from := "noreply@your-domain.com"

    // Compose message
    message := []byte(
        "From: " + from + "\r\n" +
        "To: " + to + "\r\n" +
        "Subject: " + subject + "\r\n" +
        "\r\n" +
        body + "\r\n",
    )

    // Connect to SMTP server
    client, err := smtp.Dial("smtp:25")
    if err != nil {
        return err
    }
    defer client.Close()

    // Send email
    if err := client.Mail(from); err != nil {
        return err
    }
    if err := client.Rcpt(to); err != nil {
        return err
    }

    w, err := client.Data()
    if err != nil {
        return err
    }

    _, err = w.Write(message)
    if err != nil {
        return err
    }

    err = w.Close()
    if err != nil {
        return err
    }

    return client.Quit()
}

func main() {
    err := sendEmail(
        "recipient@example.com",
        "Test Email",
        "Hello from mini-smtp-server!",
    )

    if err != nil {
        fmt.Println("Error:", err)
    } else {
        fmt.Println("Email sent successfully!")
    }
}
```

### Using gomail

```go
package main

import (
    "gopkg.in/gomail.v2"
)

func main() {
    m := gomail.NewMessage()
    m.SetHeader("From", "noreply@your-domain.com")
    m.SetHeader("To", "recipient@example.com")
    m.SetHeader("Subject", "Test Email")
    m.SetBody("text/plain", "Hello from mini-smtp-server!")

    d := gomail.Dialer{Host: "smtp", Port: 25}

    if err := d.DialAndSend(m); err != nil {
        panic(err)
    }
}
```

---

## Ruby

### Using Net::SMTP (standard library)

```ruby
require 'net/smtp'

def send_email(to, subject, body)
  from = 'noreply@your-domain.com'

  message = <<~MESSAGE
    From: #{from}
    To: #{to}
    Subject: #{subject}

    #{body}
  MESSAGE

  Net::SMTP.start('smtp', 25) do |smtp|
    smtp.send_message message, from, to
  end

  puts 'Email sent successfully!'
end

send_email(
  'recipient@example.com',
  'Test Email',
  'Hello from mini-smtp-server!'
)
```

### Using Mail gem

```ruby
require 'mail'

Mail.defaults do
  delivery_method :smtp, {
    address: 'smtp',
    port: 25,
    enable_starttls_auto: false
  }
end

Mail.deliver do
  from     'noreply@your-domain.com'
  to       'recipient@example.com'
  subject  'Test Email'
  body     'Hello from mini-smtp-server!'
end

puts 'Email sent successfully!'
```

### Using Rails ActionMailer

```ruby
# config/environments/production.rb (or development.rb)
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: 'smtp',
  port: 25,
  enable_starttls_auto: false
}

# app/mailers/notification_mailer.rb
class NotificationMailer < ApplicationMailer
  default from: 'noreply@your-domain.com'

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome!')
  end
end

# Usage
NotificationMailer.welcome_email(user).deliver_now
```

---

## Docker Environment Variables

For all examples above, when running in Docker, make sure your application can reach the SMTP server:

```yaml
# docker-compose.yml
services:
  your-app:
    environment:
      - SMTP_HOST=smtp
      - SMTP_PORT=25
      - MAIL_FROM=noreply@your-domain.com
    networks:
      - mail-network

networks:
  mail-network:
    external: true
    name: mail-network
```

---

## Testing

You can test email sending with any of these examples by:

1. Running mini-smtp-server: `docker-compose up -d`
2. Updating recipient email in the code
3. Running your application
4. Checking logs: `docker logs mini-smtp-server`
5. Verifying DKIM in received email headers

---

**Need help with another language or framework? Check the [README.md](README.md) or open an issue!**
