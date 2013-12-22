require 'yaml'
require 'fileutils'

module HCl
  class Task < TimesheetResource
    def self.cache_tasks_hash day_entry_hash
      tasks = day_entry_hash['projects'].
        map { |p| p['tasks'].each {|t| new t.merge(project:p) } }.flatten.uniq
      unless tasks.empty?
        FileUtils.mkdir_p(cache_dir)
        File.open(cache_file, 'w') do |f|
          f.write tasks.to_yaml
        end
      end
    end

    def self.cache_tasks doc
      tasks = []
      doc.root.elements.collect('projects/project') do |project_elem|
        project = Project.new xml_to_hash(project_elem)
        tasks.concat(project_elem.elements.collect('tasks/task') do |task|
          new xml_to_hash(task).merge(:project => project)
        end)
      end
      unless tasks.empty?
        FileUtils.mkdir_p(cache_dir)
        File.open(cache_file, 'w') do |f|
          f.write tasks.uniq.to_yaml
        end
      end
    end

    def self.cache_file
      File.join(cache_dir, 'tasks.yml')
    end

    def self.cache_dir
      File.join(HCl::App::HCL_DIR, 'cache')
    end

    def self.all
      tasks = File.exists?(cache_file) ? YAML.load(File.read(cache_file)) : []
      tasks = tasks.sort do |a,b|
        r = a.project.client <=> b.project.client
        r = a.project.name <=> b.project.name if r == 0
        r = a.name <=> b.name if r == 0
        r
      end
      tasks
    end

    def self.find project_id, id
      all.detect do |t|
        t.project.id.to_i == project_id.to_i && t.id.to_i == id.to_i
      end
    end

    def to_s
      if project.code.empty?
        "#{project.client} - #{project.name} - #{name}"
      else
        "#{project.client} - [#{project.code}] #{project.name} - #{name}"
      end
    end

    def add opts
      notes = opts[:note]
      starting_time = opts[:starting_time] || 0
      days = DayEntry.from_xml Task.post("daily/add", <<-EOT)
      <request>
        <notes>#{notes}</notes>
        <hours>#{starting_time}</hours>
        <project_id type="integer">#{project.id}</project_id>
        <task_id type="integer">#{id}</task_id>
        <spent_at type="date">#{Date.today}</spent_at>
      </request>
      EOT
      days.first
    end

    def start opts
      day = add opts
      if day.running?
        day
      else
        DayEntry.from_xml(Task.get("daily/timer/#{day.id}")).first
      end
    end
  end
end

