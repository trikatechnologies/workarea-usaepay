require 'workarea'
require 'workarea/storefront'
require 'workarea/admin'
require 'workarea/usaepay/engine'
require 'workarea/usaepay/version'
require 'usaepay/gateway'
require 'usaepay/bogus_usaepay'

module Workarea
  module Usaepay
    # Credentials for PayFlowPro from Rails secrets.
    #
    # @return [Hash]
    def self.credentials
      return {} unless Rails.application.secrets.usaepay_transaction_gateway.present?
      Rails.application.secrets.usaepay_transaction_gateway.symbolize_keys
    end

    # Conditionally use the real gateway when secrets are present.
    # Otherwise, use the bogus gateway.
    #
    # @return [ActiveMerchant::Billing::Gateway]
    def self.gateway
      Workarea.config.gateways.credit_card
    end

    def self.gateway=(gateway)
      Workarea.config.gateways.credit_card = gateway
    end

    def self.auto_initialize_gateway
      if credentials.present?
        if Rails.env.test?
          self.gateway = ActiveMerchant::Billing::BogusUsaEpayGateway.new credentials
        else
          self.gateway = ActiveMerchant::Billing::UsaEpayCustom.new credentials
        end
      else
        self.gateway = ActiveMerchant::Billing::BogusUsaEpayGateway.new
      end
    end
  end
end
