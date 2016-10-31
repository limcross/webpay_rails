### Unreleased

#### bug fixes
* fix response verification

#### enhancements
* add support for nullify method
* raise detailed execptions when rescued from Savon::SOAPFault
* group certificates and private keys on Vault
* improve execptions when missing certificates, private_keys or commerce_code, and when set an invalid environment
* add support for certificates and private key as a files
* replace specific exceptions by generic exceptions with more detailed explanations
* add an option for disable the auto acknowledgement on transaction_result method

### 1.0.3 - 2016-09-15

#### bug fixes
* add missing error

### 1.0.2 - 2016-08-30

#### enhancements
* add rails logger support for savon
* add missing attributes on transanction result (`session_id`, `card_expiration_date`, `shares_number`)

### 1.0.1 - 2016-08-26

#### bug fixes
* Fix bug transanction_result approved? (by @isseu)

### 1.0.0 - 2016-08-06

* Add test for init_transaction.
* Rewrite official webpay sdk v1.1.0 for extend models on rails.
