require 'yaml'
require 'fileutils'

module HCl
  class Task < TimesheetResource
    def self.cache_tasks_hash day_entry_hash
      tasks = day_entry_hash[:projects].
        map { |p| p[:tasks].map {|t| new t.merge(project:Project.new(p)) } }.flatten.uniq
      unless tasks.empty?
        FileUtils.mkdir_p(cache_dir)
        File.open(cache_file, 'w') do |f|
          f.write tasks.to_yaml
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

    def add http, opts
      notes = opts[:note]
      starting_time = opts[:starting_time] || 0
      spent_at = opts[:spent_at] || Date.today
      DayEntry.new http.post("daily/add", {
        notes: notes,
        hours: starting_time,
        project_id: project.id,
        task_id: id,
        spent_at: spent_at
      })
    end

    def start http, opts
      day = add http, opts
      if day.running?
        day
      else
        DayEntry.new http.get("daily/timer/#{day.id}")
      end
    end
  end
end

