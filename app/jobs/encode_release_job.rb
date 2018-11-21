class EncodeReleaseJob < ApplicationJob
  require 'timeout'

  def perform(release)
    puts '------------Start--------------'
    begin
      status = Timeout::timeout(3600) {
        TransloaditApi::EncodeRelease.new(release).call
      }
    rescue Timeout::Error
      release.failed!
    end
    puts '---'*100
    puts '---End----'
    release.update(encode_status: nil) if release.pending?
  end
end
