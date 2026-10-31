# Course scope and original teaching examples. No course PDFs are runtime dependencies.
learning_path_labels <- c("STATS125 Core"="core", "Optional STATS210 preview"="preview",
                         "Further exploration (optional)"="further")
learning_path <- function(value) {
  if (length(value)!=1L || is.na(value) || !value %in% c(unname(learning_path_labels),"legacy")) "core" else value
}
learning_path_label <- function(value) {
  if (identical(value,"legacy")) return("Original question library")
  names(learning_path_labels)[match(learning_path(value),learning_path_labels)]
}
learning_fraction <- function(n,d=1) {
  a<-abs(n);b<-abs(d)
  while(b!=0) {r<-a%%b;a<-b;b<-r}
  if(a==0) return("0")
  n<-n/a;d<-d/a
  if(d==1) as.character(n) else paste0(n,"/",d)
}
learning_math <- function(text) paste0("\\(",text,"\\)")
learning_counts <- function() matrix(c(6,4,2,8),nrow=2,byrow=TRUE)
learning_pmf_example <- function(key) {
  weights<-switch(key,cards=c(188,16,16,1),counts20=as.vector(t(learning_counts())),
                  zero_x=c(0,0,1,3),stop("Unknown worked example."))
  data.frame(x=c(0,0,1,1),y=c(0,1,0,1),p_input=as.character(weights),
             p_value=weights/sum(weights),id=1:4)
}
learning_pmf_notes <- c(
  cards="Two draws without replacement from 52 cards (4 Aces). X and Y indicate whether the first and second cards are Aces. The four probabilities follow from 48 non-Aces and 4 Aces.",
  counts20="Worked example: 20 fictional observations. Rows X=0/1 and columns Y=0/1 have counts 6,4 / 2,8. X and Y are binary indicators; these are not real student data.",
  zero_x="Boundary example: P(X=0)=0. Conditioning on X=0 is undefined; conditioning on X=1 gives probabilities 1/4 and 3/4.")
learning_pmf_caption <- function(df) {
  if(is.null(df) || nrow(df)!=4L) return("Custom joint PMF: define what X, Y and their units represent before interpreting the table.")
  for(key in names(learning_pmf_notes)) {
    target<-learning_pmf_example(key)
    a<-df[order(df$x,df$y),c("x","y","p_value")]
    if(identical(as.numeric(a$x),target$x) && identical(as.numeric(a$y),target$y) &&
       all(abs(a$p_value-target$p_value)<1e-12)) return(unname(learning_pmf_notes[key]))
  }
  "Custom joint PMF: define what X, Y and their units represent before interpreting the table."
}
learning_table <- function(counts=FALSE,zero=FALSE) {
  values<-if(zero) c("0","0","1/4","3/4") else if(counts) as.character(as.vector(t(learning_counts()))) else
    vapply(as.vector(t(learning_counts())),learning_fraction,character(1),d=sum(learning_counts()))
  paste0("<table class='pmf-table'><caption>",if(counts) "Frequencies (20 fictional observations)" else "Joint PMF",
    "</caption><thead><tr><th>X / Y</th><th>Y=0</th><th>Y=1</th></tr></thead><tbody>",
    "<tr><th>X=0</th><td>",values[1],"</td><td>",values[2],"</td></tr>",
    "<tr><th>X=1</th><td>",values[3],"</td><td>",values[4],"</td></tr></tbody></table>")
}
learning_field <- function(key,label,expected,kind="numeric",choices=NULL,nonnegative=TRUE) {
  list(key=key,label=label,expected=expected,kind=kind,choices=choices,nonnegative=nonnegative)
}
learning_new_questions <- function(module) {
  m<-learning_math;num<-learning_field
  counts<-learning_counts();p<-counts/sum(counts);fx<-rowSums(p);fy<-colSums(p)
  q<-function(id,title,question,fields,hint1,hint2,solution,table=learning_table(),example="counts20",stage="joint") {
    list(id=id,title=title,question=shiny::HTML(question),story=shiny::HTML(table),
      table_ui=shiny::HTML(table),fields=fields,hint1=shiny::HTML(hint1),hint2=shiny::HTML(hint2),
      solution=shiny::HTML(paste0("<b>Solution:</b><br>",solution)),track="core",stage=stage,
      pmf_example=example,ans_val=NA_real_,ans_frac=NA_character_)
  }
  switch(module,
    overview=list(q(1,"CDF endpoints for a Bernoulli variable",
      paste0("Let ",m("X\\sim Bernoulli(0.4)"),". Find the four quantities. Compare strict and inclusive inequalities."),
      list(num("cdf0","F(0)",.6),num("less1","P(X < 1)",.6),num("atleast1","P(X >= 1)",.4),num("greater1","P(X > 1)",0)),
      "Write the two possible outcomes and their probabilities before using the CDF.",
      paste0(m("P(X=0)=0.6,\\ P(X=1)=0.4"),". The CDF includes its endpoint."),
      paste0(m("F(0)=0.6,\\ P(X<1)=0.6,\\ P(X\\ge1)=0.4,\\ P(X>1)=0"),
             ". For integer-valued X, P(X >= k) = 1 - F(k-1)."),table="",example=NULL,stage="foundation")),
    joint=list(
      q(11,"From frequencies to a joint PMF","Divide each frequency by the total. Enter the four joint probabilities, in the labelled cells.",
        lapply(1:4,function(i) num(paste0("cell",i),c("P(X=0,Y=0)","P(X=0,Y=1)","P(X=1,Y=0)","P(X=1,Y=1)")[i],as.vector(t(p))[i])),
        "Find the total number of observations; every cell uses the same denominator.",
        "The total is 6+4+2+8=20. Check that the probabilities are non-negative and sum to 1.",
        "The four probabilities are 6/20=3/10, 4/20=1/5, 2/20=1/10, 8/20=2/5; their sum is 1.",table=learning_table(TRUE)),
      q(12,"Find the marginal probabilities","Find P(X=1) and P(Y=1) from the joint PMF.",
        list(num("px","P(X=1)",fx[2]),num("py","P(Y=1)",fy[2])),
        "To find a marginal, fix one variable and add over the other variable.",
        "For X=1 add its row. For Y=1 add its column.","P(X=1)=(2+8)/20=1/2; P(Y=1)=(4+8)/20=3/5."),
      q(13,"Check independence","Are X and Y independent? Supply the joint probability and the product of the marginals used in your check.",
        list(num("independent","Are X and Y independent?","no","choice",c("Choose an answer"="","Independent"="yes","Not independent"="no")),
          num("joint","P(X=1,Y=1)",p[2,2]),num("product","P(X=1) P(Y=1)",fx[2]*fy[2])),
        "Independence requires f(X,Y)=f(X)f(Y) at every pair of supported values.",
        "One unequal pair disproves independence; one equal pair would not prove it.",
        "They are not independent: 2/5 is not equal to (1/2)(3/5)=3/10.")),
    conditional=list(
      q(14,"Joint, conditional, and reversed conditional probabilities",
        "Compute all three quantities. Explain to yourself which event supplies each denominator.",
        list(num("joint","P(X=1,Y=1)",p[2,2]),num("ygivenx","P(Y=1 | X=1)",p[2,2]/fx[2]),num("xgiveny","P(X=1 | Y=1)",p[2,2]/fy[2])),
        "A joint probability uses the full population. A conditional probability uses only the cases meeting the condition.",
        "The joint cell has count 8. There are 10 observations with X=1 and 12 with Y=1.",
        "The answers are 8/20=2/5, 8/10=4/5, and 8/12=2/3. Reversing the condition changes the denominator.",stage="conditional"),
      q(15,"A condition with zero probability","How should the conditional distribution given X=0 be described? Also compute P(Y=1 | X=1).",
        list(num("defined","Distribution of Y given X=0","undefined","choice",c("Choose an answer"="","Undefined"="undefined","All probabilities are zero"="zero","Uniform"="uniform")),num("positive","P(Y=1 | X=1)",.75)),
        "Compute P(X=0) before dividing. A conditional PMF is defined here only for a positive conditioning probability.",
        "The first row has total zero; the second row has total one.",
        "Given X=0 the distribution is undefined, not an all-zero PMF. Given X=1, P(Y=1 | X=1)=3/4.",
        table=learning_table(zero=TRUE),example="zero_x",stage="conditional"),
      q(16,"Specify a conditional Hypergeometric model",
        "A bag contains 20 tokens, 8 red. Given the sample size X=5, draw without replacement and let Y count red tokens. Name the distribution, specify n, M and N, and find E[Y | X=5].",
        list(num("model","Distribution name","Hypergeometric","distribution"),num("n","n (sample size)",5),num("M","M (red tokens)",8),num("N","N (population size)",20),num("mean","E[Y | X=5]",2)),
        "The population is finite and sampling is without replacement. Distinguish the sample size from the population size.",
        "Use Hypergeometric(n,M,N), with support max(0,n+M-N),...,min(n,M), and mean nM/N.",
        "Y | X=5 is Hypergeometric(n=5,M=8,N=20), with support 0,...,5. Its mean is 5*8/20=2.",table="",example=NULL,stage="conditional"),
      q(17,"Specify a conditional Negative Binomial model",
        "Given a worker category S=s, attempts are independent with success probability 1/4. Let Y count failures before the second success. Name the distribution, specify k and p, and find E[Y | S=s].",
        list(num("model","Distribution name","Negative Binomial","distribution"),num("k","k (target successes)",2),num("p","p (success probability)",.25),num("mean","E[Y | S=s]",6)),
        "The number of trials is not fixed: the experiment stops on the second success, and Y counts failures.",
        "The course convention is failures before the k-th success. Its mean is k(1-p)/p.",
        "Y | S=s is Negative Binomial(k=2,p=1/4), with support 0,1,2,... . The conditional mean is 2*(3/4)/(1/4)=6.",table="",example=NULL,stage="conditional")),
    expectation=list(
      q(10,"Conditional means and the law of total expectation",
        "For the binary Y in the table, compute both conditional means, E[Y], the weighted average of the conditional means, and E[XY].",
        list(num("mean0","E[Y | X=0]",p[1,2]/fx[1]),num("mean1","E[Y | X=1]",p[2,2]/fx[2]),
          num("mean","E[Y]",fy[2]),num("total","Sum_x E[Y | X=x] P(X=x)",fy[2]),num("product","E[XY]",p[2,2])),
        "Since Y is 0 or 1, its mean equals the probability of 1. First fix X; then average using the X marginal.",
        "P(X=0)=P(X=1)=1/2. The two conditional probabilities of Y=1 are 2/5 and 4/5.",
        "The answers are 2/5, 4/5, 3/5, 3/5 and 2/5. The law of total expectation gives (1/2)(2/5)+(1/2)(4/5)=3/5. E[Y | X=x] is a number for fixed x; E[Y | X] varies with X.",stage="conditional"),
      q(11,"A discrete second moment and variance",
        "Let Z be uniform on the integers 1,2,3,4,5 (DU(5)). Find E[Z^2], (E[Z])^2 and Var(Z).",
        list(num("second","E[Z^2]",11),num("squared_mean","(E[Z])^2",9),num("variance","Var(Z)",2)),
        "Use a discrete sum. Squaring each outcome before averaging differs from squaring the mean.",
        "E[Z]=3 and E[Z^2]=(1+4+9+16+25)/5. Then subtract the squared mean to get the variance.",
        "E[Z^2]=55/5=11; (E[Z])^2=9; Var(Z)=11-9=2. No continuous distribution or integral is needed.",table="",example=NULL,stage="foundation")),
    list())
}
learning_questions <- function(legacy,module) {
  prefix<-c(joint="J",conditional="C",expectation="E",overview="O")[[module]]
  tagged<-lapply(legacy,function(q) {
    q$key<-sprintf("%s%02d",prefix,q$id);q$legacy<-TRUE
    q$track<-switch(module,joint="core",conditional=if(q$id<=6) "core" else if(q$id %in% c(10,13)) "further" else "preview",
      expectation=if(q$id %in% c(1,2,7,8)) "core" else if(q$id %in% c(4,6)) "further" else "preview")
    q$stage<-if(module=="expectation" && q$id %in% c(1,2)) "foundation" else if(module=="joint") "joint" else "conditional"
    q$title<-paste0(module," exercise ",q$id)
    if(module=="conditional") q$plot_examples<-switch(as.character(q$id),`3`=c("eggs_sunny","eggs_cloudy"),`4`="eggs_cloudy",
      `7`="rain",`8`="rain",`9`="normal65",`10`="normal65",`11`="uniform140",`12`="uniform140",NULL)
    if(module=="expectation") q$plot_examples<-switch(as.character(q$id),`2`="eggs_sunny",`3`="rain",`4`="uniform100",`5`="normal50",
      `6`="exp2",`8`=c("eggs_sunny","eggs_cloudy"),`9`="normal65",NULL)
    if(module=="conditional" && q$id %in% 1:2) q$plot_examples<-"corn5"
    if(module=="conditional" && q$id %in% 5:6) q$plot_examples<-"novice"
    if(module=="expectation" && q$id %in% c(1,7)) q$plot_examples<-"corn10"
    q
  })
  fresh<-lapply(learning_new_questions(module),function(q) {
    q$key<-sprintf("%s%02d",prefix,q$id);q$legacy<-FALSE
    if(module=="overview") q$plot_examples<-"bern04"
    if(module=="expectation" && q$id==11) q$plot_examples<-"du5"
    if(module=="conditional" && q$id==16) q$plot_examples<-"tokens"
    if(module=="conditional" && q$id==17) q$plot_examples<-"worker_nb"
    q
  })
  c(tagged,fresh)
}
learning_indices <- function(questions,module,path) {
  path<-learning_path(path)
  keep<-which(vapply(questions,function(q) if(path=="legacy") isTRUE(q$legacy) else identical(q$track,path),logical(1)))
  if(path!="core") return(keep)
  priority<-switch(module,joint=c(11,1,2,7,8,9,10,12,3,4,5,6,13),
    conditional=c(14,15,1,2,3,4,5,6,16,17),expectation=c(1,2,11,7,8,10),overview=1)
  keep[order(match(vapply(questions[keep],`[[`,numeric(1),"id"),priority))]
}
learning_graph_examples <- function() list(
  bern04=list(label="CDF practice: Bernoulli(p=0.4)",paths=c("core","legacy"),type="discrete",dist="bern",inputs=list(p_bern=.4),x=0,
    note="P(X=0)=0.6 and P(X=1)=0.4. The CDF at 0 includes X=0; compare strict and inclusive inequalities."),
  corn5=list(label="Corn: Binomial(n=5,p=0.2)",paths=c("core","legacy"),type="discrete",dist="binom",inputs=list(n=5,p=.2),x=0,
    note="Given 5 inspected plants, Y is Binomial(5,0.2). P(Y>=1)=1-F(0)=0.67232."),
  corn10=list(label="Corn: Binomial(n=10,p=0.2), mean 2",paths=c("core","legacy"),type="discrete",dist="binom",inputs=list(n=10,p=.2),x=2,
    note="With 10 independent inspected plants, the expected count is np=10*0.2=2."),
  novice=list(label="Novice: Geometric(p=0.2), failures Z",paths=c("core","legacy"),type="discrete",dist="geom",inputs=list(pg=.2),x=1,
    note="Z counts failures before success, and attempts Y=Z+1. P(Y>=3)=P(Z>=2)=1-F_Z(1)=0.64."),
  du5=list(label="Second moments: Discrete Uniform on 1,...,5",paths=c("core","legacy"),type="discrete",dist="dunifd",inputs=list(N_du=5),x=3,
    note="DU(5) has mean 3. Averaging squared outcomes gives E[Z^2]=11; variance=11-9=2."),
  tokens=list(label="Red tokens: Hypergeometric(n=5,M=8,N=20)",paths=c("core","legacy"),type="discrete",dist="hyper",inputs=list(n_hy=5,M_hy=8,N_hy=20),x=2,
    note="Draw 5 tokens without replacement from 20, including 8 red. The conditional mean is nM/N=2."),
  worker_nb=list(label="Worker: Negative Binomial(k=2,p=1/4)",paths=c("core","legacy"),type="discrete",dist="nbinom",inputs=list(r_nb=2,p_nb=.25),x=6,
    note="Y counts failures before the second success in independent trials. Its mean is k(1-p)/p=6."),
  eggs_cloudy=list(label="Cloudy eggs: Poisson(12), P(Y <= 10)",paths=c("core","legacy"),type="discrete",dist="pois",inputs=list(lambda=12),x=10,
    note="Cloudy: 2 eggs/hour for 6 hours gives lambda=12. The highlighted CDF at 10 is P(Y <= 10), about 0.3472."),
  eggs_sunny=list(label="Sunny eggs: Poisson(24), mean 24",paths=c("core","legacy"),type="discrete",dist="pois",inputs=list(lambda=24),x=24,
    note="Sunny: 4 eggs/hour for 6 hours gives lambda=24. The count mean is 24; the rate per hour is 4."),
  rain=list(label="Rain waiting time: Exponential(rate=0.5)",paths=c("preview","further","legacy"),type="continuous",dist="exp",inputs=list(rate_exp=.5),x=2,
    note="Cloudy rain model: rate=0.5 per hour, mean waiting time=2 hours. The CDF at 2 is about 0.6321."),
  normal65=list(label="Strawberries: Normal(mean=65, sd=3)",paths=c("preview","further","legacy"),type="continuous",dist="norm",inputs=list(mean_norm=65,sd_norm=3),x=70,
    note="For fertility X=3, the mean is 65 and the variance is 9 (standard deviation 3). The tail above 70 is 1-F(70), about 0.0478."),
  uniform140=list(label="Grazing: Uniform(0,140)",paths=c("preview","further","legacy"),type="continuous",dist="unif",inputs=list(a_unif=0,b_unif=140),x=50,
    note="At W=2, the assumed upper bound is 140. P(Y>50)=1-F(50)=90/140=9/14; a single point still has probability zero."),
  uniform100=list(label="Grazing: Uniform(0,100)",paths=c("further","legacy"),type="continuous",dist="unif",inputs=list(a_unif=0,b_unif=100),x=50,
    note="The optional second-moment exercise uses Uniform(0,100). The density is 1/100 and E[X^2]=10000/3."),
  normal50=list(label="Strawberries: Normal(mean=50, sd=3)",paths=c("preview","further","legacy"),type="continuous",dist="norm",inputs=list(mean_norm=50,sd_norm=3),x=50,
    note="Mean 50, variance 9, standard deviation 3. The expected squared deviation from the mean is the variance."),
  exp2=list(label="Waiting time: Exponential(rate=2)",paths=c("further","legacy"),type="continuous",dist="exp",inputs=list(rate_exp=2),x=.5,
    note="The optional second-moment exercise uses rate 2; the mean is 1/2 and E[X^2]=1/2."))

learning_continuous_choices <- function(path) {
  choices<-c("Uniform"="unif","Exponential"="exp","Gamma"="gamma","Normal"="norm", "Beta"="beta","Chi-Squared"="chisq","Student's t"="t","F"="f")
  switch(learning_path(path),core=character(0),preview=choices[choices %in% c("unif","exp","norm")],choices)
}
