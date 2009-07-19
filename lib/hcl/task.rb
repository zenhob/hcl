class HCl
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
end

