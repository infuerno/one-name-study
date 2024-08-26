
class BaseExtractor

  def initialize(wait_between_requests = 2)
    @wait_between_requests = wait_between_requests
    @mechanize = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
      agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    }
  end
end