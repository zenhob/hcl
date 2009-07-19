require 'rexml/document'

class HCl
  class TimesheetResource
    def self.configure opts = nil
      if opts
        self.login = opts['login']
        self.password = opts['password']
        self.subdomain = opts['subdomain']
      else
        yield self
      end
    end
  
    # configuration accessors
    %w[ login password subdomain ].each do |config_var|
      class_eval <<-EOC
        def self.#{config_var}= arg
          @@#{config_var} = arg
        end
        def self.#{config_var}
          @@#{config_var}
        end
      EOC
    end
  
    def initialize params
      @data = params
    end
  
    def self.perform action
      client = session action
      if client.http_get
        client.body_str
      else
        raise "failed"
      end
    end

    def self.send_data action, data
      client = session action
      client.multipart_form_post = true
      data_field = Curl::PostField.file('data','data') { data }
      if client.http_post data_field
        client.body_str
      else
        raise "failed"
      end
    end

    def self.session action
      client = Curl::Easy.new("https://#{subdomain}.harvestapp.com/#{action}")
      client.headers['Accept'] = 'application/xml'
      client.headers['Content-Type'] = 'application/xml'
      client.http_auth_types = Curl::CURLAUTH_BASIC
      client.userpwd = "#{login}:#{password}"
      client
      #client = Patron::Session.new
      #client.timeout = 10
      #client.username = login
      #client.password = password
      #if client.get "https://#{subdomain}.harvestapp.com/#{action}"
    end
  
    def id
      @data[:id]
    end

    def method_missing method, *args
      if @data.key? method.to_sym
        @data[method]
      else
        super
      end
    end

    def self.xml_to_hash elem
      elem.elements.map { |e| e.name }.inject({}) do |a, f|
        a[f.to_sym] = elem.elements[f].text if elem.elements[f]
        a
      end
    end
  end
  
  class Project < TimesheetResource;end

  class Task < TimesheetResource
    def self.cache_tasks doc
      tasks = []
      doc.root.elements.collect('projects/project') do |project_elem|
        project = Project.new xml_to_hash(project_elem)
        tasks.concat(project_elem.elements.collect('tasks/task') do |task|
          new xml_to_hash(task).merge(:project => project)
        end)
      end
      File.open(File.join(ENV['HOME'],'.hcl_tasks'), 'w') do |f|
        f.write tasks.uniq.to_yaml
      end
    end

    def self.all
      YAML.load File.read(File.join(ENV['HOME'],'.hcl_tasks'))
    end

    def self.find id
      all.detect {|t| t.id == id }
    end

    def to_s
      "#{project.name} #{name}"
    end

    def start *args
      notes = args.join ' '
      Task.send_data "/daily/add", <<-EOT
      <request>
        <notes>#{notes}</notes>
        <hours></hours>
        <project_id type="integer">#{project.id}</project_id>
        <task_id type="integer">#{id}</task_id>
        <spent_at type="date">#{Date.today}</spent_at>
      </request>
      EOT
    end
  end

  class DayEntry < TimesheetResource
    # Get the time sheet entries for a given day. If no date is provided
    # defaults to today.
    def self.all date = nil
      url = date.nil? ? 'daily' : "daily/#{date.strftime '%j/%Y'}"
      doc = REXML::Document.new perform url
      Task.cache_tasks doc
      doc.root.elements.collect('day_entries/day_entry') do |day|
        new xml_to_hash(day)
      end
    end

    def initialize *args
      super
      # TODO cache client/project names and ids
    end
  end
end
