# Spacetime Tutorials

A tutorial will be used to help the user learn to use the program. It can also
be used to teach the core concepts of special relativity.
The user will be able to select one of several tutorials and then run it.

Tutorials will be stored as text files. Prebuilt tutorials can be served by the
server that also serves the app or built into the app.
Optionally, we can allow users to write their own tutorials and share them with
others.

## Tutorial Steps

A tutorial is going to be a list of steps. Each step might contain several sub
steps. Each step will have a one-line title and some optional extra text that can be a
longer. Each step will have an "exit criterion", such as "the user clicks a
button" or "the user adjusts a slider to a target value".  A step will also
have a way to highlight what the user should do. For example: if the exit
criteria is to click a button, then that button will gently flash.
When running the tutorial, the app will start at the first step and
display the step's title and extra text. The user can go back or view previous
steps or view next steps -- but if the user just does the exit criteria then
the step finishes and the app goes to the next step.

A step might also have some output that the tutorial can use as input for
future steps. For example step 1 might be to create an train. Step 2 might be
to edit the train's color.


## Tutorial Syntax or File Format

One option is to have a tutorial be saved as a json file. That might not be
very easy to edit by a human. Another is to make it a markdown file that is
easier to read, but controls might be hard for the app to parse.

We might want to have a simple programming language for the tutorials. We can
either build the parser into the app, or have a separate app that helps edit
and verify a tutorial, and then compiles it into a json file. The json file can
be loaded and run but not edited by the app.



## Sample Tutorial

Here is a rough draft of a tutorial scrpt. When writing a tutorial, I think most
of it will be the text, with a simple description of the exit criteria.



```
Einstein came up with special relativity by thinking what it meant for the speed of light to be constant. In this tool, we’ll use a speed of 1 to make the drawings easier to understand.
> Start a new drawing
At the bottom of the application are two sliders, one for the current time and one for the observer’s velocity relative to an imaginary reference frame.
Set the velocity to -0.25
> v = 0.25
Add a person
> multi step to add a person.
Set the velocity to 0.25
> velocity = 0.25
Add a train
> multistep to add a train. Make it blue
Slide the time back and forth and notice that the person moves but the train stays still. That’s because the observer velocity is still 0.5, which is the train’s velocity. Change the velocity back to -0.25
> v = 0.25
Now slide the time back and forth and see that the train is moving.
Before the theory of relativity was invented, there were two standard theories for the speed of light: it could be like a particle whose speed was relative to its emitter, or it could be like a wave whose speed was relative to its medium. Historically, the medium for light was called the ether.
> ok
Let’s add a beam of light emitted from the middle of the train.
Let’s look at the emitter theory.
> set menu to emitter.
Set the volicy to 0.25
> v = 0.25
Add a light cone to the middle of the train.
> add yellow light in middle of the train.
(maybe select the light and move it to the middle).
Notice that in the main view, the two rays have the same speed: 1.
> ok
Slide the time back and forth. Notice that from the train’s point of view the two rays of light hit each end of the train at the same time.
Notice that the rays move at the same speed.
> ok
Now let’s look at it from the person’s view.
> v = -0.25
Slide the time back and forth.
Notice that the ray moving in the same direction of the train is faster than the ray moving backwards.
In the person’s frame of reference, the two rays of light hit the ends of the train at the same tim.
> ok
Now let’s assume that light moves through an ether.
> ether
Notice that the rays don’t have the same speed.
Change to the train’s reference.
> v = 0.25
Notice that the rays still don’t have the same speed.
Change to the ether’s reference frame.
> v = 0
Now, the rays have the same speed of 1.
Look at when the rays hit the edge of the train. Ray moving backward hits first. If you change reference frames, this is always true.
> ok
But experiments on the speed of light always showed it had the same speed – no matter what the relative speeds of the emitter and observer were.
There is a way to change coordinates that keeps the speed of light the same. It’s the Lorentz transformation.
> lorentz
Look at the train’s frame of reference.
> v = .25
Notice that the rays have the same speed, and that they hit the ends of the train at the same time.
Now look at the person’s frame
> v = 0.25
Notice that the rays still have the same speed. What changed? When the rays hit
the end of the train is no longer at the same time.

```

## Architecture & Design Review

### Step Model & Exit Criteria
* **Interactive Guidance**: Using exit criteria (such as button clicks, slider thresholds, or canvas additions) provides clear hands-on learning.
* **UI Highlighting**: Visual cues (e.g., pulsing/glowing target UI controls) help direct user focus.
* **Flexibility**: Manual navigation (Previous/Next) alongside automatic exit-criterion progression gives the user full control over the pace.
* **Variable Reference**: Steps that produce output (e.g., creating an entity) should generate or reference clear target IDs for subsequent steps.

### Format & Parsing Options
* **Human-Readable Source Format**: Markdown with embedded structured directives (YAML frontmatter per step or block directives) allows clear human editing and simple machine parsing.
* **Compilation & Validation**: Compiling human-authored tutorials into JSON artifacts (or parsing them with runtime schema validation) ensures data integrity across versions.

### Key Implementation Considerations
* **UI Target Registration**: Interactive controls (sliders, toolbar buttons, canvas elements) should register key identifiers so the tutorial engine can position highlights accurately.
* **Directive Types**:
  * **User Directives (Exit Criteria)**: Wait for state updates matching specific conditions.
  * **Script Directives (Auto-setup)**: Programmatically apply UI/scene states (e.g., setting frame velocity or switching light models).
* **Baseline State Reset**: Allow tutorials to snapshot or reset baseline scene configurations at each step boundary.

### Substeps & Composite Action Macros
* **Composite Steps**: Complex actions (e.g., `Add a blue train named T1 with velocity 0.5`) can be written by tutorial authors as single macro commands.
* **Automatic Substep Expansion**: The engine automatically expands macro steps into explicit sequential substeps for the user:
  1. Select the "Add Location" tool.
  2. Click on the canvas to place a Train.
  3. Rename the object to "T1".
  4. Change object color to blue.
  5. Set velocity to 0.5.
* **Hierarchical UI & Expandability**: The tutorial UI can present the overall step title (e.g., "Create Train T1"), while providing a collapsible checklist of substeps. Experienced users can complete the combined task in one go, while beginners can expand and follow each individual highlighted UI step.

### Dynamic & Relational Exit Criteria
* **Relational Expressions**: Exit criteria should support boolean expressions evaluating runtime entity states in specific reference frames (e.g., `abs(p1.x_obs - p2.x_obs) < 0.05` or `p1.x_world == p2.x_world`).
* **Frame Awareness**: Differentiate between observer-frame coordinates (`x_obs`, `t_obs`) and world-frame coordinates (`x_world`, `t_world`).
* **Tolerance Handling**: Provide built-in floating-point tolerance/delta checks (`abs(a - b) < delta`) so user slider adjustments easily satisfy collision/coincidence steps without requiring exact floating-point equality.

## Script Syntax Options

Here are 4 clear options for separating user-facing text from step control directives (`setup`, `exit`, `highlight`, `macro`):

### Option 1: Markdown + Blockquote Directives (Selected Preference)
Uses simple Markdown blockquotes (`>`) with prefix key-value commands.

```markdown
## Step 1: Initialize Observer
Adjust the observer's velocity slider to -0.25.

> setup: mode=lorentz
> exit: v == -0.25
> highlight: slider.v
```
* **Pros**: Simple to type and read; standard Markdown rendering ignores or styles blockquotes cleanly.
* **Cons**: Parsing complex expressions or multi-line directives can be clunky.


---

### Option 2: Fenced Code Blocks (````tutorial`)
Uses custom Markdown fenced code blocks to group step directives clearly.

```markdown
## Step 1: Initialize Observer
Adjust the observer's velocity slider to -0.25.

```tutorial
setup: mode=lorentz
exit: v == -0.25
highlight: slider.v
macro: create_location type=train name="T1"
```
```
* **Pros**: Very clean visual separation between prose and code; straightforward regex/line parsing inside fenced blocks.
* **Cons**: Takes up a few extra lines in source files.

---

### Option 3: YAML Block / Frontmatter per Step
Uses standard YAML key-value pairs per step.

```markdown
---
step: 1
title: "Initialize Observer"
setup:
  mode: lorentz
exit: "v == -0.25"
highlight: slider.v
---

Adjust the observer's velocity slider to -0.25.
```
* **Pros**: Highly structured; can be parsed directly by standard YAML parsers.
* **Cons**: Text prose is separated from step metadata by boundary lines (`---`).

---

### Option 4: HTML Comment Directives
Embeds directives inside HTML comment tags `<!-- tutorial ... -->`.

```markdown
## Step 1: Initialize Observer
Adjust the observer's velocity slider to -0.25.

<!-- tutorial
setup: mode=lorentz
exit: v == -0.25
highlight: slider.v
-->
```
* **Pros**: In standard Markdown viewers, control directives are hidden, leaving only human readable lesson text.
* **Cons**: Can make directives harder to spot while editing without a syntax-highlighting editor.


---

## Tutorial UI & Interaction Design

### Tutorial Overlay Panel
* **Positioning**: Docked card overlay (top right or bottom panel) over the Spacetime workspace.
* **Header Controls**: Title, step index (`Step 2 of 8`), Progress bar, and navigation (`< Prev`, `Next >`, `Close`).
* **Body Content**: Step instructions rendered via Markdown text.
* **Collapsible Substeps**: For macro steps, a toggleable breakdown checklist showing granular substep requirements and completion checkmarks.

### Visual Highlighting System
* **Pulse/Glow Overlay**: Target UI controls (toolbar buttons, sliders, inspector fields) render a animated highlight border when referenced in the active step's `highlight:` directive.
* **Canvas Focus**: Canvas entities referenced in steps display an animated target reticle in the drawing area.

---

## Storage & File Management

### Custom File Extension & MIME Type
* **File Extension**: `.sptut` (Spacetime Tutorial) or `.md`
* **JSON Schema MIME**: `application/x-spacetime-tutorial+json` or plain `text/markdown`
* **Google Drive Integration**:
  * Save and load `.sptut` files alongside standard `.sp` / `.json` drawing files in Google Drive.
  * Custom Google Drive MIME type (`application/x-spacetime-tutorial`) to allow filtering tutorials in file pickers.

### Tutorial Editor & Authoring Workflow
* **Built-in Script Editor**: An inline syntax editor (similar to `JsonSyntaxEditorDialog`) with live parsing, error checking, and step preview.
* **Local & Remote Storage**:
  * **Prebuilt Tutorials**: Bundled as app web/assets (`assets/tutorials/*.sptut`).
  * **User Tutorials**: Saved locally, copied to clipboard, or synced to Google Drive via `FileHolder` implementations.
