require 'test_helper'

class DayEntryTest < HCl::TestCase
  def test_project_info
    register_uri(:get, '/daily', {projects:[], day_entries:[{project_id:123}]})
    register_uri(:get, '/projects/123', {project:{name:'fun times'}})
    assert_equal 'fun times', HCl::DayEntry.today.first.project_info.name
  end

  def test_all_today_empty
    register_uri(:get, '/daily', {projects:[],day_entries:[]})
    assert HCl::DayEntry.today.empty?
  end

  def test_all_today
    register_uri(:get, '/daily', {projects:[], day_entries:[{id:1,note:'hi'}]})
    assert_equal 'hi', HCl::DayEntry.today.first.note
  end

  def test_all_with_date
    register_uri(:get, '/daily/013/2013', {projects:[], day_entries:[{id:1,note:'hi'}]})
    assert_equal 'hi', HCl::DayEntry.daily(Date.civil(2013,1,13)).first.note
  end

  def test_toggle
    entry = HCl::DayEntry.new(id:123)
    register_uri(:get, '/daily/timer/123', {note:'hi'})
    entry.toggle
  end

  def test_cancel_success
    entry = HCl::DayEntry.new(id:123)
    register_uri(:delete, '/daily/delete/123')
    assert entry.cancel
  end

  def test_cancel_failure
    entry = HCl::DayEntry.new(id:123)
    HCl::Net.expects(:delete).raises(HCl::HarvestMiddleware::Failure)
    assert !entry.cancel
  end

  def test_to_s
    entry = HCl::DayEntry.new \
      hours: '1.2', client: 'Taco Town', project:'Pizza Taco', task:'Preparation'
    assert_equal "Taco Town - Pizza Taco - Preparation (1:12)", entry.to_s
  end

  def test_append_note
    entry = HCl::DayEntry.new(:id => '1', :notes => 'yourmom.', :hours => '1.0')
    HCl::Net.stubs(:post)
    entry.append_note('hi world')
    assert_equal "yourmom.\nhi world", entry.notes
  end

  def test_append_note_to_empty
    entry = HCl::DayEntry.new(:id => '1', :notes => nil, :hours => '1.0')
    HCl::Net.stubs(:post)
    entry.append_note('hi world')
    assert_equal 'hi world', entry.notes
  end
end
