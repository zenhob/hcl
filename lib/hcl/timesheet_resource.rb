module HCl
  class TimesheetResource
    def initialize params
      @data = params
    end

    def id
      @data[:id]
    end

    def method_missing method, *args
      @data.key?(method.to_sym) ? @data[method] : super
    end

    def respond_to? method, include_all=false
      (@data && @data.key?(method.to_sym)) || super
    end

    class << self
      def _prepare_resource name, *args, &url_cb
        ((@resources ||= {})[name] = {}).tap do |res|
          opt_or_cb = args.pop
          res[:url_cb] = url_cb
          res[:opts] = {}
          case opt_or_cb
          when String
            res[:url_cb] = ->() { opt_or_cb }
            res[:opts] = args.pop || {}
          when Hash
            res[:opts] = opt_or_cb
            url = args.pop
            res[:url_cb] = ->() { url } if url
          end
        end
      end

      def resources name, *args, &url_cb
        res = _prepare_resource name, *args, &url_cb
        cls = res[:opts][:class_name] ? HCl.const_get(res[:opts][:class_name]) : self
        method = cls == self ? :define_singleton_method : :define_method
        send(method, name) do |http, *args|
          url = instance_exec *args, &res[:url_cb]
          cb = res[:opts][:load_cb]
          http.get(url).tap{|e| cb.call(e) if cb }[cls.collection_name].map{|e|new(e)}
        end
      end

      def resource name, *args, &url_cb
        res = _prepare_resource name, *args, &url_cb
        cls = res[:opts][:class_name] ? HCl.const_get(res[:opts][:class_name]) : self
        method = cls == self ? :define_singleton_method : :define_method
        send(method, name) do |http, *args|
          url = instance_exec *args, &res[:url_cb]
          cb = res[:opts][:load_cb]
          cls.new http.get(url).tap{|e| cb.call(e) if cb }[cls.underscore_name]
        end
      end

      def underscore_name
        @underscore_name ||= name.split('::').last.split(/(?=[A-Z])/).map(&:downcase).join('_').to_sym
      end

      def collection_name name=nil
        name ? (@collection_name = name) : @collection_name
      end
    end
  end
end
