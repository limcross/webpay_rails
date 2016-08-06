# WebpayRails

[![Build Status](https://travis-ci.com/limcross/webpay_rails.svg?token=x5A97TEb4yuM38tPHvD3&branch=master)](https://travis-ci.com/limcross/webpay_rails)
[![Code Climate](https://codeclimate.com/github/limcross/webpay_rails/badges/gpa.svg)](https://codeclimate.com/github/limcross/webpay_rails)

WebpayRails is an easy solution for integrate Transbank Webpay in Rails applications.

## Getting started
You can add it to your `Gemfile`:

```ruby
gem 'webpay_rails'
```

Run the bundle command to install it.

### Configuring models
After that, extend the model to `WebpayRails` and add `webpay_rails` to this, like below.


```ruby
class Order < ActiveRecord::Base
  extend WebpayRails

  webpay_rails({
    private_key: '-----BEGIN RSA PRIVATE KEY-----
...
-----END RSA PRIVATE KEY-----',
    public_cert: '-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----',
    webpay_cert: '-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----',
    commerce_code: 123456789
  })
end
```

Optionally you can define the 'wsdl_path' to specify that you want to use.

Obviously all these values should not be defined directly in the model. It is strongly recommended to use environment variables for this ([dotenv](https://github.com/bkeepers/dotenv)).

### Using WebpayRails

#### Initializing a transaction

First we need to initialize an transaction, like below:

```ruby
@transaction = Order.init_transaction(amount, buy_order, session_id, return_url, final_url)
```

Where `amount` is an _integer_ that define the amount receivable, `buy_order` is an _intenger_ that define the order number of the buy, `session_id` is an _string_ that define a local variable that will be returned as part of the result of the transaction, `return_url` and `final_url` are an _string_ for the redirections.

This method return a `Transaction` object, that contain a `redirection url` and `token` for redirect the customer through POST method, like below.

```erb
<% if @transaction.success? %>
  <%= form_tag(@transaction.url, method: "post") do %>
    <%= hidden_field_tag(:token_ws, @transaction.token) %>
    <%= submit_tag("Pagar con Webpay")
  <%= end %>
<% end %>
```

Once Webpay displays the form of payment and authorization of the bank, the customer will send back to the `return_url` with a token indicating the transaction. (If the customer cancels the transaction is directly returned to the `final_url`)

#### Getting the result of a transaction
