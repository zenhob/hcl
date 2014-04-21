
class TaskTest < HCl::TestCase
  def test_cache_file
    assert_equal "#{HCl::App::HCL_DIR}/cache/tasks.yml", HCl::Task.cache_file
  end

  def test_cache_tasks_hash
    HCl::Task.cache_tasks_hash({ projects: [ {
        name: "taco tasks",
        id: 3,
        client: "Taco Town",
        tasks: [{
          name: "frying tortilla",
          id: 12,
          billable: true
        }]
      }, {
        name: "burrito tasks",
        id: 5,
        client: "Burritoville",
        tasks: [{
          name: "wrapping",
          id: 16,
          billable: true
        }]
      } ]})
    assert_equal 2, HCl::Task.all.size
    assert_equal 'wrapping', HCl::Task.all.first.name
    assert_equal 'frying tortilla', HCl::Task.all.last.name
  end

  def test_add
    task = HCl::Task.new(id:1, project:HCl::Project.new({id:2}))
    register_uri(:post, '/daily/add', {
      note:'good stuff', hours:0.2, project_id:2, task_id:1, spent_at: Date.today})
    entry = task.add(http, note:'good stuff', starting_time:0.2)
    assert_equal 'good stuff', entry.note
  end

  def test_start_running
    task = HCl::Task.new(id:1, project:HCl::Project.new({id:2}))
    register_uri(:post, '/daily/add', {
      note:'good stuff', timer_started_at:DateTime.now,
      hours:0.2, project_id:2, task_id:1, spent_at: Date.today})
    entry = task.start(http, note:'good stuff', starting_time:0.2)
    assert_equal 'good stuff', entry.note
  end

  def test_start_then_toggle
    task = HCl::Task.new(id:1, project:HCl::Project.new({id:2}))
    register_uri(:post, '/daily/add', {id:123, note:'woot'})
    register_uri(:get, '/daily/timer/123', {note:'good stuff', hours:0.2,
                                            project_id:2, task_id:1, spent_at: Date.today})
    entry = task.start(http, note:'good stuff', starting_time:0.2)
    assert_equal 'good stuff', entry.note
  end
end
