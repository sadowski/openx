module OpenX
  module Services
    class Base
      extend  Persistance::ClassMethods
      include Persistance::InstanceMethods
      include Comparable

      class << self
        attr_accessor :translations
        attr_writer   :connection
        attr_accessor :create, :update, :delete, :find_one, :find_all

        def establish_connection(conn)
          conn = OpenX::Services.establish_connection(conn) if conn.is_a?(Hash)
          self.connection = conn
        end

        def with_connection(temporary)
          current = @connection
          begin
            establish_connection(temporary)
            yield
          ensure
            establish_connection(current)
          end
        end

        def connection
          @connection = nil unless defined?(@connection)
          @connection || OpenX::Services.default_connection
        end

        def remote
          connection.remote
        end

        def has_one(*things)
          things.each do |thing|
            attr_writer :"#{thing}"
            define_method(:"#{thing}") do
              klass = thing.to_s.capitalize.gsub(/_[a-z]/) { |m| m[1].chr.upcase }
              klass = OpenX::Services.const_get(:"#{klass}")
              klass.find(send("#{thing}_id"))
            end
          end
        end

        def openx_accessor(accessor_map)
          @translations ||= {}
          @translations = accessor_map.merge(@translations)
          accessor_map.each do |ruby,openx|
            attr_accessor :"#{ruby}"
          end
        end
      end

      def initialize(params = {})
        @id = nil
        params.each { |k,v| send(:"#{k}=", v) }
      end

      def new_record?
        @id.nil?
      end

      def <=>(other)
        self.id <=> other.id
      end

      protected

        def connection
          self.class.connection
        end

        def remote
          self.class.remote
        end

    end
  end
end
