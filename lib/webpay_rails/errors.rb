module WebpayRails
  class FailedInitTransaction < StandardError
  end
  class FailedGetResult < StandardError
  end
  class InvalidResultResponse < StandardError
  end
  class FailedAcknowledgeTransaction < StandardError
  end
  class InvalidAcknowledgeResponse < StandardError
  end
end
