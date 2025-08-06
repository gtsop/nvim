(feature
  "Feature:" @keyword.feature)

(description) @text.description

(background
  "Background:" @keyword.background)

(scenario
  "Scenario:" @keyword.scenario)

(scenario
  (title) @text.title)

(given
  "Given" @keyword.given)

(given
  (and "And" @keyword.given_and))

(when
  "When" @keyword.when)

(when
  (and "And" @keyword.when_and))

(then
  "Then" @keyword.then)

(then
  (and "And" @keyword.then_and))

