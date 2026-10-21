game_discrete_UI <- function(id) {
  ns <- NS(id)
  fluidPage(
    tags$head(
      tags$style(HTML("
        #game1 {
          background-color: #1c1c2b;
          color: #ecf0f1;
          font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
          min-height: 100vh;
          padding: 10px;
        }

        #game1 h1, #game1 h2, #game1 h3 {
          color: #3498db;
          text-align: center;
          font-weight: bold;
          margin-top: 20px;
          margin-bottom: 20px;
        }

        #game1 .well {
          background-color: #2c3e50;
          border: 1px solid #34495e;
          border-radius: 8px;
          box-shadow: 0px 2px 6px rgba(0,0,0,0.5);
          color: #ecf0f1;
          max-width: 800px;
          margin: auto;
          margin-top: 5px !important;
          margin-bottom: 5px !important;
          padding: 10px !important;
        }

        #game1 .btn {
          display: block;
          margin: 8px auto;
          font-weight: bold;
          border: none;
          border-radius: 6px;
          padding: 10px 20px;
        }

        #game1 .btn-primary { background-color: #2ecc71; color: white; }
        #game1 .btn-primary:hover { background-color: #27ae60; }
        #game1 .btn-success { background-color: #3498db; color: white; }
        #game1 .btn-success:hover { background-color: #2980b9; }
        #game1 b, #game1 strong { color: #3498db !important; font-weight: bold; }
      "))
    ),
    div(id = "game1",
        uiOutput(ns("mainUI"))
    )
  )
}

game_discrete_Server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    step <- reactiveVal(0)
  
  total_steps <- 7
  
  # ---- Score Tracker ----
  score_tracker <- reactiveValues(
    Poisson = 0,
    DU = 0,
    Bernoulli = 0,
    Geometric = 0,
    Hypergeo = 0,
    Binomial = 0,
    NegBin = 0
  )
  
  # ---- Helper: Map step -> distribution name ----
  current_distribution <- function() {
    switch(as.character(step()),
           "1" = "Poisson",
           "2" = "DU",
           "3" = "Bernoulli",
           "4" = "Geometric",
           "5" = "Hypergeo",
           "6" = "Binomial",
           "7" = "NegBin",
           NULL)
  }

  stories <- list(
    list(
      correct="Poisson",
      reason="This case reflects the count of rare events within a fixed time or space interval, where events occur independently and with a constant average rate.",
      transition="You share your statistical modeling with your superior. Realizing the gravity of the situation, he immediately calls headquarters for reinforcements before stepping out of the car.",
      analysis="X ~ Poisson(λ)<br>
- Random variable X: The number of events (e.g., gunshots) in a fixed time interval.<br>  
- Parameter λ: The expected number of events per interval (intensity parameter).<br>  
- Detective’s insight: Poisson arises naturally from a Poisson process, modeling scattered, irregular events over time or space.<br><br>
Characteristic check for X<br>
- Event type: Counts of events in a fixed interval.<br>
- Expectation: The mean number of events per interval is constant (λ).<br>
- Independence: Event counts in disjoint intervals are independent.<br>
Conclusion: Poisson — models rare events occurring randomly but with a constant average rate.",
      hints = list(
        "Bernoulli"         = list(
          hint1="Think again: this isn’t a single yes/no outcome, but multiple scattered events over time.",
          hint2="Bernoulli only covers one trial; here we are counting events within a fixed interval."
        ),
        "Binomial"          = list(
          hint1="Notice: there is no fixed number of trials here.",
          hint2="Binomial requires n fixed trials with constant probability; here there is no fixed n, only the total number of events in the interval."
        ),
        "Geometric"         = list(
          hint1="This isn’t about waiting until the first success.",
          hint2="Geometric models the waiting time to the first success; here we are counting all events in a window of time."
        ),
        "Negative Binomial" = list(
          hint1="There is no target of reaching the k-th success here.",
          hint2="Negative Binomial counts the number of failures before the k-th success; here there is no such success target, just a count of events."
        ),
        "Hypergeometric"    = list(
          hint1="There is no finite population being sampled from here.",
          hint2="Hypergeometric involves sampling without replacement; here the events occur randomly in time or space, not from a finite population."
        ),
        "Discrete Uniform"  = list(
          hint1="Not every outcome has equal probability in this case.",
          hint2="Uniform assumes all outcomes are equally likely; here the probabilities of different counts depend on the average rate parameter."
        )
      )
    ),
    
    list(
      correct="Discrete Uniform",
      reason="This case involves a finite set of possible outcomes, each with exactly the same probability of occurring. In other words, if there are N hiding spots, each one has probability 1/N of being chosen — precisely the situation modeled by the Discrete Uniform distribution.",
      transition="The harbor at night is vast and complex:<br><img src='img/5.png' style='display:block; margin:auto; width:60%; max-width:600px;'><br> Stacked containers, warehouses filled with cargo, docked fishing boats, and the lighthouse by the shore — all could serve as temporary hiding spots. With no further clues, you and your superior decide to begin searching from the nearest warehouse district.",
      analysis="X ~ DU(N)<br>
- Random variable X: The index of the hiding spot, chosen from {1, 2, …, N}.<br>  
- Parameter N: The total number of possible hiding spots.<br>  
- Probability: Each outcome has probability 1/N, equally likely.<br>  
- Detective’s insight: When no option is more suspicious, every possibility is equally likely.<br><br>
Characteristic check for X<br>
- Outcome space: Finite set {1, …, N}.<br>
- Probability: All outcomes have the same probability.<br>
- Note: Unlike Bernoulli trials, the probability of success p is not constant across repeated draws, so DU is not part of the Bernoulli-trial family.<br>
Conclusion: Discrete Uniform — every outcome is equally likely.",
      hints = list(
        "Bernoulli"         = list(
          hint1="Is this only about two possible outcomes?",
          hint2="Bernoulli handles binary results; here we are considering more than two possibilities."
        ),
        "Binomial"          = list(
          hint1="Does this involve repeated independent trials?",
          hint2="Binomial requires a fixed number of trials; here it is just a single random selection."
        ),
        "Geometric"         = list(
          hint1="Is there any waiting process involved?",
          hint2="Geometric models waiting until the first success; here there is no waiting, just one random outcome."
        ),
        "Negative Binomial" = list(
          hint1="Does this involve accumulating multiple successes?",
          hint2="Negative Binomial counts the number of failures before the k-th success; here it is only one draw."
        ),
        "Hypergeometric"    = list(
          hint1="Does the probability change as you sample?",
          hint2="Hypergeometric probabilities change without replacement; here the probabilities remain fixed."
        ),
        "Poisson"           = list(
          hint1="Is this about counting events in a time interval?",
          hint2="Poisson models counts of events over time; here we are not counting events in time but choosing among a finite set."
        )
      )
    ),
    
    list(
      correct = "Bernoulli",
      reason  = "This case is a classic Bernoulli trial: only two outcomes are possible—success or failure.",
      
      transition = "After carefully searching two warehouses, you peer through a dusty window and catch a fleeting shadow moving inside the next one.<br><br>
The moonlight flickers, uncertain, making it hard to confirm. You whisper your suspicion to your superior.<br><br>
Exchanging a quick glance, he signals decisively: break the door.<img src='img/6.jpg' style='display:block; margin:auto; width:60%; max-width:600px;'>
With a thunderous crash, the heavy iron door bursts open. The beam of a flashlight cuts through the darkness—two smugglers crouch behind cargo crates!
Startled, one tries to escape, but your superior blocks the way with a commanding shout, and you rush forward, pinning the fugitive to the ground.
Shaken and defeated, the suspects surrender without resistance.<br><br>
Inwardly, you affirm your judgment: this was a Bernoulli trial. Despite earlier failures, tonight you seized the ‘success’ outcome.",
      
      analysis = "Y ~ Bernoulli(p)<br>
- Random variable Y: Whether the warehouse contains suspects (1 = yes, 0 = no).<br>
- Parameter p: Probability of success (occupied).<br>
- Detective’s insight: A single yes/no judgment defines the outcome.<br><br>
Property check for Y<br>
(i) Binary outcome? Yes<br>
(ii) Constant success probability? Yes (p given)<br>
(iii) Independent trials? N.A. (single trial)<br>
Conclusion: Bernoulli — a single yes/no experiment.",
      
      hints = list(
        "Binomial" = list(
          hint1 = "Is this many trials at once?",
          hint2 = "Binomial involves a fixed number of n trials; here it is only one trial."
        ),
        "Geometric" = list(
          hint1 = "Is there any waiting process here?",
          hint2 = "Geometric is about waiting for the first success; here there is no waiting, just a single outcome."
        ),
        "Negative Binomial" = list(
          hint1 = "Is this about waiting for multiple successes?",
          hint2 = "Negative Binomial targets the k-th success; here there is no such accumulation, just one attempt."
        ),
        "Hypergeometric" = list(
          hint1 = "Are we sampling from a larger population?",
          hint2 = "Hypergeometric involves sampling without replacement; here we are not drawing from a finite set."
        ),
        "Discrete Uniform" = list(
          hint1 = "Are all possible values equally likely?",
          hint2 = "Uniform spreads probability across many values; here there are only two possible outcomes."
        ),
        "Poisson" = list(
          hint1 = "Are we counting multiple events in a time interval?",
          hint2 = "Poisson models counts of events in time or space; here it is just one binary decision."
        )
      )
    ),
    
    list(
      correct="Geometric",
      reason="The geometric distribution describes the number of failures in independent trials before the first success occurs.",
      transition = "You quickly estimate the number of cargo holds and make a decisive suggestion to your superior:<br><br>
“According to the expectation of the geometric distribution, two people conducting a full-scale search is inefficient. Let’s wait for reinforcements before carrying out a systematic sweep. For now, we should pursue the fugitive before he disappears.”<br><br>
Your superior nods in agreement, and you both turn immediately to track the possibly wounded gang member.<br><br>
<img src='img/8.png' style='display:block; margin:auto; width:60%; max-width:600px; margin-top:15px; margin-bottom:15px;'><br><br>
Following the trail through the harbor, you soon discover a streak of blood at the back door of a warehouse, winding its way toward the lighthouse by the sea.",
      analysis="X ~ Geometric(p)<br>
- Random variable X: The number of failures before the first success.<br>  
- Parameter p: Probability of success in each trial.<br>  
- Detective’s insight: Geometric models the patience of repeated attempts until the first success.<br><br>
Property check for X<br>
(i) Binary outcome? Yes<br>
(ii) Constant success probability? Yes<br>
(iii) Independent trials? Yes<br>
Conclusion: Geometric — failures before the first success.",
      hints = list(
        "Bernoulli"         = list(
          hint1="Is this only a single attempt?",
          hint2="Bernoulli is just one trial; here we are considering repeated trials until a success occurs."
        ),
        "Binomial"          = list(
          hint1="Is the number of trials fixed beforehand?",
          hint2="Binomial requires a fixed n; here the number of trials is not predetermined."
        ),
        "Negative Binomial" = list(
          hint1="Are we waiting for more than one success?",
          hint2="Negative Binomial counts the number of failures before the k-th success; here it stops as soon as the first success occurs."
        ),
        "Hypergeometric"    = list(
          hint1="Does the probability change from trial to trial?",
          hint2="Hypergeometric probabilities vary without replacement; here each trial has the same success probability."
        ),
        "Discrete Uniform"  = list(
          hint1="Is this simply about all outcomes being equally likely?",
          hint2="Uniform assumes each value has the same chance; here the focus is on a waiting process for the first success."
        ),
        "Poisson"           = list(
          hint1="Is this about counting events in a fixed interval of time or space?",
          hint2="Poisson models counts in intervals; here the concern is how many trials it takes until the first success."
        )
      )
    ),
    
    list(
      correct = "Hypergeometric",
      reason  = "This case involves sampling without replacement, where the probability of success changes after each draw.",
      
      transition = "As one hostage after another was released, the tension grew heavier with each passing moment.<br><br>
Finally, when the fourth person was brought into the safe zone, the captured gang members pointed him out: he was the accomplice who had tried to keep the goods all to himself.<br><br>
At that very moment, reinforcements arrived, and together you began the final stage of wrapping up the case.",
      
      analysis = "X ~ Hypergeometric(n, M, N)<br>
- Random variable X: Number of criminals among n released individuals.<br><br>
<b>Parameter meanings:</b><br>
• N — total number of hostages (population size)<br>
• M — number of criminals among them (successes in population)<br>
• n — number of people released and checked (sample size)<br><br>
<b>Example:</b> Suppose there are N = 10 hostages in total, among whom M = 3 are criminals.  
You check n = 4 of them — then X counts how many of those 4 are criminals.<br><br>
<b>Detective’s insight:</b> Probabilities change after each draw — unlike the Binomial case where trials are independent.<br><br>
Characteristic check for X<br>
• Sampling: Without replacement.<br>
• Probability: Changes after each draw.<br>
• Finite population: N total, M marked as 'success'.<br><br>
<b>Conclusion:</b> Hypergeometric — sampling without replacement from a finite population.",
      
      hints = list(
        "Bernoulli" = list(
          hint1 = "Is this just a single yes/no judgment?",
          hint2 = "Bernoulli is one trial only; here we are considering multiple draws from a group."
        ),
        "Binomial" = list(
          hint1 = "Does the probability remain constant?",
          hint2 = "Binomial assumes a fixed probability of success across trials; here the probability changes after each draw."
        ),
        "Geometric" = list(
          hint1 = "Are we waiting until the first success?",
          hint2 = "Geometric focuses on the waiting time for the first success; here the focus is on sampling several items from a group."
        ),
        "Negative Binomial" = list(
          hint1 = "Are we targeting the k-th success over repeated independent trials?",
          hint2 = "Negative Binomial involves waiting for the k-th success; here the sampling comes from a finite group without replacement."
        ),
        "Discrete Uniform" = list(
          hint1 = "Are all outcomes equally likely?",
          hint2 = "Uniform gives equal chance to each outcome; here probabilities differ depending on the number of successes left in the group."
        ),
        "Poisson" = list(
          hint1 = "Is this about counting events in a time or space interval?",
          hint2 = "Poisson models counts of events over time or space; here we are drawing from a fixed population without replacement."
        )
      )
    ),
    
    list(
      correct="Binomial",
      reason="This case reflects a fixed number of independent Bernoulli trials, where the outcome is the total number of successes.",
      transition="After a round of careful inspections, you and your team discover contraband hidden in warehouses 1, 3, 4, 6, and 9—five successful finds out of ten searches in total.",
      analysis="X ~ Binomial(n, p)<br>
- Random variable X: Number of successes in n independent Bernoulli trials.<br>  
- Parameters: n fixed trials, success probability p.<br>  
- Detective’s insight: Each trial is a Bernoulli trial with the same probability of success; X counts the total number of successes out of these n trials.<br><br>
Property check for X<br>
(i) Binary outcome? Yes<br>
(ii) Constant success probability? Yes<br>
(iii) Independent trials? Yes<br>
Conclusion: Binomial — counts the number of successes in n independent Bernoulli trials.",
      hints = list(
        "Bernoulli"         = list(
          hint1="Is this only a single trial?",
          hint2="Bernoulli covers just one trial; here we are considering multiple trials."
        ),
        "Geometric"         = list(
          hint1="Is this about waiting until the first success?",
          hint2="Geometric focuses on the trial of the first success; here the total number of successes across fixed trials matters."
        ),
        "Negative Binomial" = list(
          hint1="Is this about waiting for the k-th success?",
          hint2="Negative Binomial counts the number of failures before the k-th success; here the number of trials is fixed in advance."
        ),
        "Hypergeometric"    = list(
          hint1="Does the probability of success change after each draw?",
          hint2="Hypergeometric probabilities change without replacement; here the probability stays the same on each trial."
        ),
        "Discrete Uniform"  = list(
          hint1="Are all outcomes equally likely?",
          hint2="Uniform assumes each outcome has the same chance; here some numbers of successes are more likely than others."
        ),
        "Poisson"           = list(
          hint1="Is this about events occurring in a continuous time or space interval?",
          hint2="Poisson models counts in an interval; here we have a fixed number of independent trials."
        )
      )
    ),
    
    list(
      correct="Negative Binomial",
      reason="This case describes waiting for the k-th success: X equals the number of failures before achieving the k-th success.",
      transition="Following your advice, the laboratory carefully rationed its limited reagents.<br>
      <img src='img/11.png' style='display:block; margin:auto; width:60%; max-width:600px; margin-top:15px; margin-bottom:15px;'>
      <br> Sure enough, before even half of the stock was consumed, the 10th dangerous compound was successfully detected, completing the chain of evidence.<br><br>
Your superior let out a long breath, relief softening his voice:<br>
“Well done. Thanks to your reasoning, we neither wasted precious reagents nor missed the critical window for evidence collection.”<br><br>
As the cap of the final vial snapped shut, the night wind over the harbor carried with it, at last, a touch of calm.",
      analysis="X ~ NegBin(k, p)<br>
- Random variable X: The number of failures before the k-th success.<br>  
- Parameters: k = target successes, p = probability of success on each trial.<br>  
- Detective’s insight: The Negative Binomial extends the Geometric distribution. Geometric counts failures before the first success (k=1), while Negative Binomial counts failures before the k-th success.<br><br>
Property check for X<br>
(i) Binary outcome? Yes<br>
(ii) Constant success probability? Yes<br>
(iii) Independent trials? Yes<br>
Conclusion: Negative Binomial — counts the number of failures before the k-th success.",
      hints = list(
        "Bernoulli"         = list(
          hint1="Is this only a single trial?",
          hint2="Bernoulli covers just one yes/no trial; here the process continues across many trials."
        ),
        "Binomial"          = list(
          hint1="Is the number of trials fixed in advance?",
          hint2="Binomial requires a predetermined n; here the trials continue until a target number of successes is reached."
        ),
        "Geometric"         = list(
          hint1="Are we only waiting for the very first success?",
          hint2="Geometric stops at the first success; here the process continues until more than one success is achieved."
        ),
        "Hypergeometric"    = list(
          hint1="Does the probability of success change after each draw?",
          hint2="Hypergeometric probabilities change without replacement; here each trial has the same success probability."
        ),
        "Discrete Uniform"  = list(
          hint1="Are all outcomes equally likely?",
          hint2="Uniform assumes every value has the same chance; here probabilities depend on the number of successes accumulated."
        ),
        "Poisson"           = list(
          hint1="Is this about counting events in a fixed time or space interval?",
          hint2="Poisson models counts in time or space intervals; here we count failures before the k-th success in independent Bernoulli trials."
        )
      )
  )
) 
  
  wrongCounts <- reactiveValues()
  observe({
    for(i in 1:total_steps){
      key <- as.character(i)
      if(is.null(wrongCounts[[key]])) wrongCounts[[key]] <- 0
    }
  })
  
  caseUI <- function(n, text){
    fluidPage(
      div(style="max-width:800px; margin:auto; text-align:center;",
          h3(sprintf("Chapter %d/%d", n, total_steps))),
      wellPanel(h4(""), HTML(text)),
      wellPanel(
        h4("Please select the most appropriate distribution"),
        radioButtons(ns(paste0("dist", n)), "Your Selection：",
                     choices=c("Bernoulli","Binomial","Geometric",
                               "Negative Binomial","Hypergeometric",
                               "Discrete Uniform","Poisson"))
      ),
      actionButton(ns(paste0("submit", n)), "Determine", class="btn-primary"),
      uiOutput(ns(paste0("feedback", n)))
    )
  }
  
  output$mainUI <- renderUI({
    cur <- step()
    
    if(cur == 0){
      tagList(
        div(style = "max-width:800px; margin:auto; text-align:center;",
            h1("The Discrete Probability Detective")
        ),
        img(src = "img/1.png", 
            width = "60%", 
            style = "display:block; margin-left:auto; margin-right:auto; margin-bottom:10px;margin-top:10px; width:60%; max-width:600px;"
        ),
        wellPanel(
          p("You have just graduated with a degree in Data Science. Since childhood, you’ve been fascinated by deduction and detective work, and now you’ve decided to bring your talent for probability and statistics into the real world. Returning to your hometown by the sea, you join the local police force as a trainee assistant."),
          p(HTML("One evening, while on patrol with your superior, the station receives a strange report: a resident claims to have heard <b>suspicious gunfire</b> nearby. In a quiet town like yours, such an incident is no small matter. With the other officers already dispatched elsewhere, your superior decides to take you along in person.")),
          p("This will be your first time participating in an actual emergency case outside the classroom—a trial by fire, and the toughest test since you joined the force.")
        ),
        img(src = "img/2.png", 
            width = "60%",
            style = "display:block; margin-left:auto; margin-right:auto; margin-bottom:10px;margin-top:10px; width:60%; max-width:600px;"
        ),
        div(
          align = "center",
          h4("Your choice is:"),
          actionButton(ns("startBtn"), "Immediate Response", class="btn-success")
        )
      )
    }
    
    else if(cur == 1){
      caseUI(1, "
You choose to accompany your superior to handle the case. Having just received your driver’s license over the holidays, you are assigned to take the wheel, while your superior rides shotgun, keeping in contact with the caller over the radio to gather more details.<br><img src='img/3.jpg' style='display:block; margin:auto; width:60%; max-width:600px; margin-bottom:5px;'><br>
Soon, you learn that <b>the first gunshot occurred about twenty minutes ago</b>. <b>During the following ten minutes, several more shots were heard—sporadic and scattered rather than concentrated.</b><br><br>
Drawing on your knowledge of statistics, you realize that events like these, occurring irregularly within a fixed period of time, can often be modeled with a particular distribution. This insight might prove useful to the investigation.
")
    }
    
    else if(cur == 2){
      caseUI(2, "
Five minutes later, you and your superior arrive at the reporting resident’s house.<br><br>
The neighborhood is in panic—residents have already gathered together, trying to check for outsiders. From their testimonies, you quickly triangulate the source of the gunshots to a suspicious area: the town’s harbor.<br><br>
After calming the crowd, you drive straight to the docks. At the gate, however, there is no sign of the night guard, forcing you and your superior to disembark and proceed inside on foot.<br><br>
Within the harbor complex, you spot a small cargo vessel moored nearby, half-loaded and eerily empty. On its deck, several crates of contraband lie carelessly uncovered—evidence that this is indeed a smuggling group’s base of operations.<br>
<img src='img/4.png' style='display:block; margin:auto; width:60%; max-width:600px;'>
Your superior frowns, speaking in a low voice:<br>
“It seems they panicked after the gunfire drew attention, fleeing before they could move all the goods. But with the sirens already sounding, they couldn’t have gone far. They must still be hiding somewhere in this harbor.”<br><br>
The night air hangs heavy over the docks. Stacked containers, warehouses packed with goods, fishing boats at berth, and the lighthouse at the shore—all could serve as hiding spots.<br><br>
With just the two of you, charging recklessly in without backup would be far too dangerous.<br><br>
Glancing around sharply, your superior whispers:<br>
“Any of these places could be their hideout. We don’t have extra intelligence to single one out. That means <b>we must assume—the probability of them hiding in any location is the same.</b> We’ll need to prioritize sealing off the most accessible spots, then search them one by one.”<br><br>
In your mind, the reasoning is clear: when no single place is more suspicious than another, each hiding spot must be equally likely. Now, ask yourself: which probability distribution models this assumption?
")
    }
    
    else if(cur == 3){
      caseUI(3, "
The night is dim, a cold wind carrying the briny scent of the sea. The wire fence rattles faintly in the breeze.<br><br>  
With no further intelligence, <b>each warehouse could just as well conceal smugglers—or be completely empty</b>.<br><br>  
Your superior leans close and whispers:  
“We can’t act rashly now. First we need to determine one thing: is there anyone inside, or not?”<br><br>
In that instant, you realize exactly which distribution this situation belongs to.
")
    }
    
    else if(cur == 4){
      caseUI(4, "
You escort the two captured suspects out of the warehouse. Under questioning, they reveal that the gunfire actually came from a third accomplice.<br><br>
This man, disgruntled over the division of spoils, attempted to keep the goods for himself and clashed violently with the others.<br><img src='img/7.png' style='display:block; margin:auto; width:60%; max-width:600px;'>
<br>In the shootout, he was wounded and fled the scene with the crucial cargo manifest still in his possession. Without that list, it would be nearly impossible to identify which warehouses contain contraband.
<br><br>Before you looms a mountain of warehouses, yet your manpower is severely limited. After a moment’s thought, you begin to reason:  
“If it’s just the two of us starting a full-scale search now, then <b>each attempt will either uncover contraband (success) or come up empty (failure).</b>  
<br><br>The real question is: <b>before we achieve our first success, how many failures might we face?</b> And how much delay could that impose on the entire operation?”
")
    }
    
    else if(cur == 5){
      caseUI(5, "
You push open the heavy iron door of the lighthouse—only to be startled by the sight inside.<br><br>
<b>Seven hostages</b> sit bound and blindfolded, each bearing minor injuries. They all insist they are innocent: some claim to be night-shift guards from the harbor, others fishermen from nearby boats, still others repairmen sent to fix the lighthouse in an emergency. Yet most of them are strangers to one another.<br><br>
<img src='img/9.png' style='display:block; margin:auto; width:60%; max-width:600px; margin-top:15px; margin-bottom:15px;'><br><br>
From the testimony of the captured smugglers, your superior suspects the truth: <b>the third gunman, wounded in the earlier clash, is very likely hiding among these seven people</b>.<br><br>
But since he does not know his accomplices have already been caught, the situation is delicate. To avoid alarming him—and to prevent harm to the innocents—you turn to a familiar principle from statistics.<br><br>
<b>You carefully untie and release the hostages one by one, in a random sequence, and each person is identified by the captured gang members as they enter the safe zone.</b>
")
    }
    
    else if(cur == 6){
      caseUI(6, "
Relying on the last smuggler’s incomplete cargo manifest, you can only narrow it down: <b>the main contraband is scattered somewhere within five of the ten warehouses, though exactly which ones remain uncertain.</b><br><br>  
To resolve this, you organize your team to systematically search all ten warehouses.<br>
<img src='img/10.png' style='display:block; margin:auto; width:60%; max-width:600px; margin-top:15px; margin-bottom:15px;'>
<br> <b>Each search is a Bernoulli trial: in one warehouse you may uncover contraband (success), in another you may find nothing at all (failure).</b>
")
    }
    else if(cur == 7){
      caseUI(7, "
The confiscated contraband is sealed one batch at a time, but a new dilemma soon arises.<br><br>
Your superior’s brow furrows:  
“To complete the chain of evidence, the lab must detect at least ten dangerous compounds. But the reagents for chemical analysis are extremely limited. If we use them all at once, there may not be enough left for subsequent tests. Yet if we wait for supplies to be transferred from outside, we’ll miss the critical window for evidence.”<br><br>
You glance at the mountain of contraband and quickly begin reasoning:  
<b>Each test of a batch will either detect a dangerous compound (success) or not (failure). The probability of success is roughly constant, and the tests are independent.</b><br><br>
The critical question becomes: <b>before the 10th success, how many failures will occur?</b><br><br>
Lifting your head with confidence, you declare to your superior:  
“Sir, there’s no need to hesitate. Even with limited stock, I can model whether the current supply is sufficient to detect ten compounds within the time limit. This is exactly the kind of statistical problem that can be described by a specific distribution.”  
")
    }
    
    else {
      fluidPage(
        div(style = "max-width:800px; margin:auto; text-align:center;",
            h2("THE END")
        ),
        wellPanel(
          style = "max-width:800px; margin:auto;",
          
          p("The case was finally over. A salty night breeze swept through the harbor, carrying away the stench of blood and gunpowder.
     By the time your field report reached headquarters, the clock had already struck three in the morning."),
          
          p("From the very first gunshots echoing in the distance, to the sudden raid at the docks, from the tense rescue of hostages to the meticulous collection of evidence—
     you had peeled back each layer of this mystery with the very tools you once thought belonged only in classrooms: probability and statistics."),
          
          p(HTML("The <b>Poisson distribution</b> had guided you through the scattered rhythm of gunfire, revealing the crime scene’s location.")),
          
          p(HTML("The <b>Discrete Uniform distribution</b> reminded you that, with no extra clues, every hiding place was equally suspicious.")),
          
          p(HTML("The <b>Bernoulli trial</b> forced a clear decision—was the warehouse occupied or not? That single judgment led to the capture of the lookout.")),
          
          p(HTML("The <b>Geometric distribution</b> taught you patience: instead of wasting effort on blind searches, you convinced your superior to pursue the fugitive before he slipped away.")),
          
          p(HTML("The <b>Hypergeometric distribution</b> helped you navigate the most delicate moment—identifying the hidden criminal among frightened hostages without risking their lives.")),
          
          p(HTML("The <b>Binomial distribution</b> framed your warehouse sweeps: each search an independent trial, each discovery a step toward certainty.")),
          
          p(HTML("And the <b>Negative Binomial distribution</b> gave structure to your final challenge—balancing limited reagents with the need to uncover enough dangerous compounds to complete the chain of evidence.")),
          
          img(src = "img/12.png",style = "display:block; margin:auto; width:70%; max-width:700px; margin-top:20px; margin-bottom:20px;"),
          
          p("When your superior finally set down the report, he remained silent for a long time. Then, with the faintest smile, he clapped you on the shoulder.
     “Who would’ve thought,” he said, “that those probability models from your university days would become weapons sharper than any gun. This town is fortunate to have you.”"),
          
          p("You lifted your gaze toward the horizon, where the first pale light of dawn spread across the sea. 
     And in that moment you knew—this wasn’t just the resolution of a single case.
     It was the good beginning of your life as a police. 
     Probability was no longer a formula etched in textbooks—it was your blade, your compass, and your most trusted ally."),
          h3("Score Summary"),
          uiOutput(ns("scoreBoard")),
          div(
            style = "text-align:center; margin-top:20px;",
            actionButton(ns("restartBtn"), "Restart Game", class = "btn-danger")
          )
        )
      )
    }
  })
  
  for(i in 1:total_steps){
    local({
      n <- i
      dist_id <- paste0("dist", n)
      submit_id <- paste0("submit", n)
      feedback_id <- paste0("feedback", n)
      next_id <- paste0("next", n)
      key <- as.character(n)
      
      observeEvent(input[[submit_id]], {
        chosen <- input[[dist_id]]
        correct <- stories[[n]]$correct
        if(is.null(chosen)) return(NULL)
        
        cnt <- isolate(wrongCounts[[key]])
        if(is.null(cnt)) cnt <- 0
        
        if(chosen == correct){
          wrongCounts[[key]] <- 0
          output[[feedback_id]] <- renderUI({
            div(style="max-width:800px; margin:auto;", 
                tagList(
                  div(style="color:green;font-weight:bold;",
                      paste("✅ Correct! This is", correct, "Distribution"),
                      br(), span(style="color:gray;", stories[[n]]$reason)),
                  if(!is.null(stories[[n]]$transition) && nchar(stories[[n]]$transition) > 0){
                    wellPanel(HTML(stories[[n]]$transition))
                  },
                  if(!is.null(stories[[n]]$analysis) && nchar(stories[[n]]$analysis) > 0){
                    wellPanel(h4("Distribution Analysis"), HTML(stories[[n]]$analysis))
                  },
                  div(
                    style = "display:flex; justify-content:space-between; gap:10px;",
                    actionButton(ns(paste0("prev", n)), "← Back", class="btn-secondary"),
                    actionButton(ns(next_id), "NEXT →", class="btn-success")
                  )
                )
            )
          })
        } else {
          cnt <- cnt + 1
          wrongCounts[[key]] <- cnt
          
          dist_name <- current_distribution()
          if (!is.null(dist_name)) {
            score_tracker[[dist_name]] <- score_tracker[[dist_name]] + 1
          }
          
          hint_set <- stories[[n]]$hints[[chosen]]
          
          if(cnt == 1 && !is.null(hint_set) && !is.null(hint_set$hint1)){
            output[[feedback_id]] <- renderUI({
              div(style="max-width:800px; margin:auto; color:orange;font-weight:bold;",
                  paste("⚠️ Hint 1:", hint_set$hint1))
            })
          } else if(cnt == 2 && !is.null(hint_set) && !is.null(hint_set$hint2)){
            output[[feedback_id]] <- renderUI({
              div(style="max-width:800px; margin:auto; color:#cc7a00;font-weight:bold;",
                  paste("⚠️ Hint 2:", hint_set$hint2))
            })
          } else {
            wrongCounts[[key]] <- 0
            output[[feedback_id]] <- renderUI({
              div(style="max-width:800px; margin:auto;", 
                  tagList(
                    div(style="color:red;font-weight:bold;",
                        paste("❌ The correct one is", correct)),
                    div(style="color:gray;", stories[[n]]$reason),
                    if(!is.null(stories[[n]]$transition) && nchar(stories[[n]]$transition) > 0){
                      wellPanel(h4("Then"), HTML(stories[[n]]$transition))
                    },
                    if(!is.null(stories[[n]]$analysis) && nchar(stories[[n]]$analysis) > 0){
                      wellPanel(h4("Distribution Analysis"), HTML(stories[[n]]$analysis))
                    },
                    div(
                      style = "display:flex; justify-content:space-between; gap:10px;",
                      actionButton(ns(paste0("prev", n)), "← Back", class="btn-secondary"),
                      actionButton(ns(next_id), "NEXT →", class="btn-success")
                    )
                  )
              )
            })
          }
        }
      })
      
      observeEvent(input[[next_id]], {
        if(step() < total_steps){
          step(step()+1)
        } else {
          step(total_steps+1)
        }
        next_key <- as.character(step())
        if(!is.null(wrongCounts[[next_key]])) wrongCounts[[next_key]] <- 0
      })
      
      observeEvent(input[[paste0("prev", n)]], {
        if (step() > 0) {
          step(step() - 1)
        }
      })
      
    })
  }
  
  # ---- Compute Score Table ----
  score_table <- reactive({
    dists <- c("Poisson","DU","Bernoulli","Geometric","Hypergeo","Binomial","NegBin")
    errors <- sapply(dists, function(d) score_tracker[[d]])
    scores <- pmax(0, 3 - errors)
    total <- sum(scores)
    data.frame(
      Distribution = dists,
      Errors = as.integer(errors),  
      Score = as.integer(scores),   
      stringsAsFactors = FALSE
    ) |> rbind(
      data.frame(
        Distribution = "Total",
        Errors = as.integer(sum(errors)),
        Score = as.integer(total)
      )
    )
  })
  
  output$scoreBoard <- renderUI({
    df <- score_table()
    tagList(
      div(
        style = "display:flex; justify-content:center; margin-top:20px; margin-bottom:10px;",
        tableOutput(ns("scoreTbl"))
      ),
      div(
        style="text-align:center; font-size:14px; color:gray; margin-top:8px;",
        "Full score: 21 points. Each question is worth 3 points. One mistake deducts 1 point. After 3 mistakes, the score for that question is 0."
      )
    )
  })
  
  output$scoreTbl <- renderTable({
    score_table()
  }, bordered = TRUE, align = "c", digits = 0)   
  
  # ---- Start Game ----
  observeEvent(input$startBtn, {
    step(1)
    
    for (i in 1:total_steps) {
      wrongCounts[[as.character(i)]] <- 0
      output[[paste0("feedback", i)]] <- renderUI(NULL)
    }
    
    for (d in c("Poisson", "DU", "Bernoulli", "Geometric", "Hypergeo", "Binomial", "NegBin")) {
      score_tracker[[d]] <- 0
    }
  })
  
  # ---- Restart Game ----
  restart_trigger <- reactiveVal(0)
  
  observeEvent(input$restartBtn, {
    restart_trigger(restart_trigger() + 1)
  })
  
  return(list(restart = restart_trigger))
  
  })  
}      