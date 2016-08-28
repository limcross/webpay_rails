# WebpayRails

[![Build Status](https://travis-ci.org/limcross/webpay_rails.svg?branch=master)](https://travis-ci.org/limcross/webpay_rails)
[![Code Climate](https://codeclimate.com/github/limcross/webpay_rails/badges/gpa.svg)](https://codeclimate.com/github/limcross/webpay_rails)
[![Gem Version](https://badge.fury.io/rb/webpay_rails.svg)](https://badge.fury.io/rb/webpay_rails)

WebpayRails is an easy solution for integrate Transbank Webpay in Rails applications.

_This gem (including certificates used in tests) was originally based on the SDK for Ruby (distributed under the **open source license**) available in www.transbankdevelopers.cl_

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
    commerce_code: 123456789,
    private_key: '-----BEGIN RSA PRIVATE KEY-----
...
-----END RSA PRIVATE KEY-----',
    public_cert: '-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----',
    webpay_cert: '-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----',
    environment: :integration,
    log: Rails.env.development?
  })
end
```

Obviously all these values should not be defined directly in the model. It is strongly recommended to use environment variables for this ([dotenv](https://github.com/bkeepers/dotenv)).

### Using WebpayRails

#### Initializing a transaction

First we need to initialize an transaction, like below:

```ruby
@transaction = Order.init_transaction(amount, buy_order, session_id, return_url, final_url)
```

Where `amount` is an __integer__ that define the amount of the transaction (_obviously_), `buy_order` is an __intenger__ that define the order number of the buy, `session_id` is an __string__ that define a local variable that will be returned as part of the result of the transaction, `return_url` and `final_url` are a __string__ for the redirections.

This method return a `Transaction` object, that contain a redirection `url` and `token` for redirect the customer through POST method, like below.

```erb
<% if @transaction.success? %>
  <%= form_tag(@transaction.url, method: "post") do %>
    <%= hidden_field_tag(:token_ws, @transaction.token) %>
    <%= submit_tag("Pagar con Webpay") %>
  <% end %>
<% end %>
```

Once Webpay displays the form of payment and authorization of the bank, the customer will send back through __POST__ method to the `return_url` with a `token_ws`. (If the customer cancels the transaction is directly returned to the `final_url` in the same way).

#### Getting the result of a transaction

When Webpay send a __POST__ to `return_url` with `token_ws`, we need to ask for the transaction result, like below.

```ruby
@result = Order.transaction_result(params[:token_ws])
```

This method return a `TransactionResult` object, that contain an `accounting_date`, `buy_order`, `card_number`, `amount`, `commerce_code`, `authorization_code`, `payment_type_code`, `response_code`, `transaction_date`, `url_redirection` and `vci`.

At this point we have confirmed the transaction with Transbank, performing the operation `acknowledge_transaction` by means of `transaction_result`.

Now we need to send back the customer to `url_redirection` with `token_ws` in the same way we did earlier in the initialization of the transaction.

#### Ending a transaction

When Webpay send customer to `final_url`, we are done. Finally the transaction has ended. :clap:

## Contributing
Any contribution is welcome. Personally I prefer to use English to do documentation and describe commits, however there is no problem if you make your comments and issues in Spanish.

### Reporting issues

Please try to answer the following questions in your bug report:

- What did you do?
- What did you expect to happen?
- What happened instead?

Make sure to include as much relevant information as possible. Ruby version,
WebpayRails version, OS version and any stack traces you have are very valuable.

### Pull Requests

- __Add tests!__ Your patch won't be accepted if it doesn't have tests.

- __Document any change in behaviour__. Make sure the README and any  relevant documentation are kept up-to-date.

- __Create topic branches__. Please don't ask us to pull from your master branch.

- __One pull request per feature__. If you want to do more than one thing, send multiple pull requests.

- __Send coherent history__. Make sure each individual commit in your pull request is meaningful. If you had to make multiple intermediate commits while developing, please squash them before sending them to us.
