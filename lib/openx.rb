module OpenX
  autoload :Image, 'openx/image'
  autoload :Invocation, 'openx/invocation'
  autoload :Services, 'openx/services'
  autoload :XmlrpcClient, 'openx/xmlrpc_client'
  autoload :XmlrpcSessionClient, 'openx/xmlrpc_client'

  @@env           = ENV['OPENX_ENV'] || 'production'
  @@config_file   = File.join(ENV['HOME'], '.openx', 'credentials.yml')
  @@configuration = nil

  DEFAULT_OPTIONS = { 'retry' => true, 'timeout' => 10 }

  class << self

    def env
      @@env
    end

    def env=(value)
      @@env = value
    end

    def configuration
      @@configuration ||= DEFAULT_OPTIONS.merge(YAML.load_file(config_file)[env])
    end

    def configuration=(value)
      @@configuration = value
    end

    def config_file
      @@config_file
    end

    def config_file=(value)
      @@config_file = value
    end

  end
end
