require 'test_helper'
class CommandTest < HCl::TestCase
  include HCl::Commands
  include HCl::Utility

  def setup
    super
    @settings = {}
  end

  # the current_time utility method needs to be deterministic
  def current_time
    'high noon'
  end

  # stub settings helpers
  def write_settings; end
  def read_settings
    @settings
  end

  def test_log_failure
    HCl::DayEntry.expects(:with_timer).returns(stub)
    assert_raises(HCl::CommandError) { log "stuff" }
  end

  def test_tasks
    HCl::Task.expects(:all).returns([HCl::Task.new(
      id:123,
      name: 'Dev',
      project: HCl::Project.new(id:456, name:'App', client:'Bob', code:'b')
    )])
    result = tasks
    assert_equal "456 123\tBob - [b] App - Dev", result
  end

  def test_show
    HCl::DayEntry.expects(:daily).returns([HCl::DayEntry.new({
      hours:'2.06',
      notes: 'hi world',
      project: 'App'
    })])
    result = show
    assert_equal \
      "\t2:03\tApp: hi world\n\t-------------\n\t2:03\ttotal (as of high noon)\n",
      result
  end

  def test_aliases
    HCl::Task.expects(:all).returns([HCl::Task.new(
      id:123,
      name: 'Dev',
      project: HCl::Project.new(id:456, name:'App', client:'Bob', code:'b')
    )])
    result = send :alias, *%w[ hcl 456 123 ]
    assert_equal '456 123', @settings['task.hcl']

    result = aliases
    assert_equal ["@hcl"], result

    result = unalias 'hcl'
    assert !@settings.key?('task.hcl'), 'hcl alias is no longer defined'
  end

  def test_start
    task = HCl::Task.new(
      id:123,
      name: 'Dev',
      project: HCl::Project.new(id:456, name:'App', client:'Bob', code:'b')
    )
    HCl::Task.expects(:find).with('456','123').returns(task)
    task.expects(:start).with(http, starting_time:nil, note:'do stuff')
    start *%w[ 456 123 do stuff ]
  end

  def test_stop
    entry = stub
    register_uri(:get, '/daily', {day_entries:[{id:123,notes:'',hours:1,client:nil,project:nil,timer_started_at:DateTime.now}]})
    register_uri(:post, '/daily/update/123', {day_entry:{notes:'all done'}})
    register_uri(:get, '/daily/timer/123')
    stop 'all done'
  end

  def test_resume
    entry = stub
    HCl::DayEntry.expects(:last).returns(entry)
    entry.expects(:toggle)
    resume
  end

  def test_resume_with_task_alias
    entry = stub
    expects(:get_task_ids).with('mytask',[]).returns(%w[ 456 789 ])
    HCl::DayEntry.expects(:last_by_task).with(http, '456', '789').returns(entry)
    entry.expects(:toggle).with(http)
    resume 'mytask'
  end

  def test_cancel
    entry = stub
    HCl::DayEntry.expects(:with_timer).with(http).returns(entry)
    entry.expects(:cancel).with(http).returns(true)
    cancel
  end

  def test_note
    entry = stub
    HCl::DayEntry.expects(:with_timer).returns(entry)
    entry.expects(:append_note).with(http, 'hi world')
    note 'hi world'
  end

  def test_note_display
    entry = stub(notes:"your face")
    HCl::DayEntry.expects(:with_timer).returns(entry)
    assert_equal "your face", note
  end

end
