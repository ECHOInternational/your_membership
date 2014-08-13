require 'yaml'
module YourMembership
  # Configuration defaults
  @config = {
    :publicKey => '',
    :privateKey => '',
    :saPasscode => '',
    :baseUri => 'https://api.yourmembership.com',
    :version => '2.00'
  }

  @valid_config_keys = @config.keys

  # Configure through hash
  # @example
  #  YourMembership.configure(:publicKey => 45G2E6DC-98NA-45W7-8493-D97C4E2C156A,
  #  :privateKey => D74H44B2-2348-4ACT-B531-45W385TGB966, :saPasscode => WPIkriJtqS4m)
  # @note The baseUri and version are both defaulted to the current API for the release version.
  def self.configure(opts = {})
    opts.each { |k, v| @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym }
  end

  # Configure through yaml file
  # @example
  #  ---
  #  publicKey: 45G2E6DC-98NA-45W7-8493-D97C4E2C156A
  #  privateKey: D74H44B2-2348-4ACT-B531-45W385TGB966
  #  saPasscode: WPIkriJtqS4m
  #  baseUri: 'https://api.yourmembership.com'
  #  version: '2.00'
  # @note The baseUri and version are both defaulted to the current API for the release version.
  def self.configure_with(path_to_yaml_file)
    config = YAML.load(IO.read(path_to_yaml_file))
    configure(config)
  end

  # Access configuration variables by calling YourMembership.config[ :attribute ]
  def self.config # rubocop:disable Style/TrivialAccessors
    @config
  end
end
