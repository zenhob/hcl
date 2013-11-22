
class Task < Test::Unit::TestCase
  def test_cache_file
    assert_equal "#{HCl::App::HCL_DIR}/cache/tasks.yml", HCl::Task.cache_file
  end

  def test_cache_tasks
    HCl::Task.cache_tasks(REXML::Document.new(<<-EOD))
<daily>
  <projects>
    <project>
      <name>Click and Type</name>
      <code></code>
      <id type="integer">3</id>
      <client>AFS</client>
      <tasks>
        <task>
          <name>Security support</name>
          <id type="integer">14</id>
          <billable type="boolean">true</billable>
        </task>
      </tasks>
    </project>
  </projects>
</daily>
    EOD
    assert_equal 1, HCl::Task.all.size
    assert_equal 'Security support', HCl::Task.all.first.name
  end
end
