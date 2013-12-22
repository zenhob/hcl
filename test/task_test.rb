
class TaskTest < HCl::TestCase
  DAILY_ENTRY = %{<daily>
    <for_day type="date">Wed, 18 Oct 2006</for_day>
    <day_entries>
      <day_entry>
        <id type="integer">195168</id>
        <client>Iridesco</client>
        <project>Harvest</project>
        <task>Backend Programming</task>
        <hours type="float">2.06</hours>
        <notes>Test api support</notes>
        <timer_started_at type="datetime">
          Wed, 18 Oct 2006 09:53:06 -0000
        </timer_started_at>
        <created_at type="datetime">Wed, 18 Oct 2006 09:53:06 -0000</created_at>
      </day_entry>
    </day_entries>
  </daily>}

  def test_add_task
    task = HCl::Task.new(id:456, project:HCl::Project.new(id:123))
    Date.expects(:today).returns('now')
    HCl::Task.expects(:post).with('daily/add', <<-EOT).returns(DAILY_ENTRY)
      <request>
        <notes>hi world</notes>
        <hours>0.5</hours>
        <project_id type="integer">123</project_id>
        <task_id type="integer">456</task_id>
        <spent_at type="date">now</spent_at>
      </request>
      EOT
    task.add note:'hi world', starting_time:0.5
  end
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
