module WebpayRails
  class Error < StandardError; end
  class FailedInitTransaction < Error; end
  class FailedGetResult < Error; end
  class InvalidResultResponse < Error; end
  class FailedAcknowledgeTransaction < Error; end
  class InvalidAcknowledgeResponse < Error; end
  class InvalidEnvironment < Error; end
  class InvalidCertificate < Error; end
  class FailedNullify < Error; end
end
