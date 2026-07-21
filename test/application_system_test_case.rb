require "test_helper"
require "axe-capybara"
require "axe/dsl"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1_400, 1_400 ]

  def assert_accessible
    assert_nothing_raised do
      Axe::DSL.expect(page).to(
        Axe::Matchers::BeAxeClean.new.according_to(
          "wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"
        )
      )
    end
  end
end
