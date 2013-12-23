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

    def respond_to? method
      (@data && @data.key?(method.to_sym)) || super
    end
  end
end
