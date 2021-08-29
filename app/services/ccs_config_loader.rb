require 'ccs'

class CcsConfigLoader
  ACCESS_TOKEN = ENV.fetch('CCS_ACCESS_TOKEN')
  PASSPHRASE = ENV.fetch('CCS_PASSPHRASE')

  def initialize(source)
    @source = source
  end

  def call
    document.split("\n").each do |line|
      key, value = line.split("=", 2)
    
      ENV.store(key, value)
    end
  end

  private

  def document
    @document ||= Ccs::Document.new(@source, ENV.fetch('CCS_ACCESS_TOKEN'), ENV.fetch('CCS_PASSPHRASE')).download
  end
end

