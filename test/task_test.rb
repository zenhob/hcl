
class TaskTest < HCl::TestCase
  def test_cache_file
    assert_equal "#{HCl::App::HCL_DIR}/cache/tasks.yml", HCl::Task.cache_file
  end

  def test_cache_tasks_hash
    HCl::Task.cache_tasks_hash({ projects: [{
      name: "Click and Type",
      id: 3,
      client: "AFS",
      tasks: [{
        name: "Security support",
        id: 14,
        billable: true
      }]
    }]})
    assert_equal 1, HCl::Task.get_all.size
    assert_equal 'Security support', HCl::Task.get_all.first.name
  end
end
