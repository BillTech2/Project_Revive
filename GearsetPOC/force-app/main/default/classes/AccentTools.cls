public without sharing class AccentTools {

    static Integer[] A_L   = new Integer[]{97};
    static Integer[] AA_LL = new Integer[]{97,97};
    static Integer[] AE_LL = new Integer[]{97,101};
    static Integer[] AO_LL = new Integer[]{97,111};
    static Integer[] AU_LL = new Integer[]{97,117};
    static Integer[] AV_LL = new Integer[]{97,118};
    static Integer[] AY_LL = new Integer[]{97,121};
    static Integer[] B_L   = new Integer[]{98};
    static Integer[] C_L   = new Integer[]{99};
    static Integer[] D_L   = new Integer[]{100};
    static Integer[] DZ_LL = new Integer[]{100,122};
    static Integer[] E_L   = new Integer[]{101};
    static Integer[] F_L   = new Integer[]{102};
    static Integer[] G_L   = new Integer[]{103};
    static Integer[] H_L   = new Integer[]{104};
    static Integer[] HV_LL = new Integer[]{104,118};
    static Integer[] I_L   = new Integer[]{105};
    static Integer[] J_L   = new Integer[]{106};
    static Integer[] K_L   = new Integer[]{107};
    static Integer[] L_L   = new Integer[]{108};
    static Integer[] LJ_LL = new Integer[]{108,106};
    static Integer[] M_L   = new Integer[]{109};
    static Integer[] N_L   = new Integer[]{110};
    static Integer[] NJ_LL = new Integer[]{110,106};
    static Integer[] O_L   = new Integer[]{111};
    static Integer[] OI_LL = new Integer[]{111,105};
    static Integer[] OU_LL = new Integer[]{111,117};
    static Integer[] OO_LL = new Integer[]{111,111};
    static Integer[] P_L   = new Integer[]{112};
    static Integer[] Q_L   = new Integer[]{113};
    static Integer[] R_L   = new Integer[]{114};
    static Integer[] S_L   = new Integer[]{115};
    static Integer[] T_L   = new Integer[]{116};
    static Integer[] TZ_LL = new Integer[]{116,122};
    static Integer[] U_L   = new Integer[]{117};
    static Integer[] V_L   = new Integer[]{118};
    static Integer[] VY_LL = new Integer[]{118,121};
    static Integer[] W_L   = new Integer[]{119};
    static Integer[] X_L   = new Integer[]{120};
    static Integer[] Y_L   = new Integer[]{121};
    static Integer[] Z_L   = new Integer[]{122};

    static Integer[] OE_LL = new Integer[]{111,101};
    static Integer[] UE_LL = new Integer[]{117,101};

    static Map<Integer, List<Integer>> DIACRITIC_MAP = new Map<Integer, List<Integer>>{
            97=>A_L,9424=>A_L,65345=>A_L,7834=>A_L,224=>A_L,225=>A_L,226=>A_L,7847=>A_L,7845=>A_L,7851=>A_L,7849=>A_L,
            227=>A_L,257=>A_L,259=>A_L,7857=>A_L,7855=>A_L,7861=>A_L,7859=>A_L,551=>A_L,481=>A_L,228=>A_L,479=>A_L,
            7843=>A_L,229=>A_L,507=>A_L,462=>A_L,513=>A_L,515=>A_L,7841=>A_L,7853=>A_L,7863=>A_L,7681=>A_L,261=>A_L,
            11365=>A_L,592=>A_L,
            42803=>AA_LL,
            230=>AE_LL,509=>AE_LL,483=>AE_LL,
            42805=>AO_LL,
            42807=>AU_LL,
            42809=>AV_LL,42811=>AV_LL,
            42813=>AY_LL,
            98=>B_L,9425=>B_L,65346=>B_L,7683=>B_L,7685=>B_L,7687=>B_L,384=>B_L,387=>B_L,595=>B_L,
            99=>C_L,9426=>C_L,65347=>C_L,263=>C_L,265=>C_L,267=>C_L,269=>C_L,231=>C_L,7689=>C_L,392=>C_L,572=>C_L,
            42815=>C_L,8580=>C_L,
            100=>D_L,9427=>D_L,65348=>D_L,7691=>D_L,271=>D_L,7693=>D_L,7697=>D_L,7699=>D_L,7695=>D_L,273=>D_L,
            396=>D_L,598=>D_L,599=>D_L,42874=>D_L,
            499=>DZ_LL,454=>DZ_LL,
            101=>E_L,9428=>E_L,65349=>E_L,232=>E_L,233=>E_L,234=>E_L,7873=>E_L,7871=>E_L,7877=>E_L,7875=>E_L,7869=>E_L,
            275=>E_L,7701=>E_L,7703=>E_L,277=>E_L,279=>E_L,235=>E_L,7867=>E_L,283=>E_L,517=>E_L,519=>E_L,7865=>E_L,
            7879=>E_L,553=>E_L,7709=>E_L,281=>E_L,7705=>E_L,7707=>E_L,583=>E_L,603=>E_L,477=>E_L,
            102=>F_L,9429=>F_L,65350=>F_L,7711=>F_L,402=>F_L,42876=>F_L,
            103=>G_L,9430=>G_L,65351=>G_L,501=>G_L,285=>G_L,7713=>G_L,287=>G_L,289=>G_L,487=>G_L,291=>G_L,485=>G_L,
            608=>G_L,42913=>G_L,7545=>G_L,42879=>G_L,
            104=>H_L,9431=>H_L,65352=>H_L,293=>H_L,7715=>H_L,7719=>H_L,543=>H_L,7717=>H_L,7721=>H_L,7723=>H_L,7830=>H_L,
            295=>H_L,11368=>H_L,11382=>H_L,613=>H_L,
            405=>HV_LL,
            105=>I_L,9432=>I_L,65353=>I_L,236=>I_L,237=>I_L,238=>I_L,297=>I_L,299=>I_L,301=>I_L,239=>I_L,7727=>I_L,
            7881=>I_L,464=>I_L,521=>I_L,523=>I_L,7883=>I_L,303=>I_L,7725=>I_L,616=>I_L,305=>I_L,
            106=>J_L,9433=>J_L,65354=>J_L,309=>J_L,496=>J_L,585=>J_L,
            107=>K_L,9434=>K_L,65355=>K_L,7729=>K_L,489=>K_L,7731=>K_L,311=>K_L,7733=>K_L,409=>K_L,11370=>K_L,
            42817=>K_L,42819=>K_L,42821=>K_L,42915=>K_L,
            108=>L_L,9435=>L_L,65356=>L_L,320=>L_L,314=>L_L,318=>L_L,7735=>L_L,7737=>L_L,316=>L_L,7741=>L_L,7739=>L_L,
            383=>L_L,322=>L_L,410=>L_L,619=>L_L,11361=>L_L,42825=>L_L,42881=>L_L,42823=>L_L,
            457=>LJ_LL,
            109=>M_L,9436=>M_L,65357=>M_L,7743=>M_L,7745=>M_L,7747=>M_L,625=>M_L,623=>M_L,
            110=>N_L,9437=>N_L,65358=>N_L,505=>N_L,324=>N_L,241=>N_L,7749=>N_L,328=>N_L,7751=>N_L,326=>N_L,7755=>N_L,
            7753=>N_L,414=>N_L,626=>N_L,329=>N_L,42897=>N_L,42917=>N_L,
            460=>NJ_LL,
            111=>O_L,9438=>O_L,65359=>O_L,242=>O_L,243=>O_L,244=>O_L,7891=>O_L,7889=>O_L,7895=>O_L,7893=>O_L,245=>O_L,
            7757=>O_L,557=>O_L,7759=>O_L,333=>O_L,7761=>O_L,7763=>O_L,335=>O_L,559=>O_L,561=>O_L,246=>O_L,555=>O_L,
            7887=>O_L,337=>O_L,466=>O_L,525=>O_L,527=>O_L,417=>O_L,7901=>O_L,7899=>O_L,7905=>O_L,7903=>O_L,7907=>O_L,
            7885=>O_L,7897=>O_L,491=>O_L,493=>O_L,248=>O_L,511=>O_L,596=>O_L,42827=>O_L,42829=>O_L,629=>O_L,
            419=>OI_LL,
            547=>OU_LL,42831=>OO_LL,
            112=>P_L,9439=>P_L,65360=>P_L,7765=>P_L,7767=>P_L,421=>P_L,7549=>P_L,42833=>P_L,42835=>P_L,42837=>P_L,
            113=>Q_L,9440=>Q_L,65361=>Q_L,587=>Q_L,42839=>Q_L,42841=>Q_L,
            114=>R_L,9441=>R_L,65362=>R_L,341=>R_L,7769=>R_L,345=>R_L,529=>R_L,531=>R_L,7771=>R_L,7773=>R_L,343=>R_L,
            7775=>R_L,589=>R_L,637=>R_L,42843=>R_L,42919=>R_L,42883=>R_L,
            115=>S_L,9442=>S_L,65363=>S_L,223=>S_L,347=>S_L,7781=>S_L,349=>S_L,7777=>S_L,353=>S_L,7783=>S_L,7779=>S_L,
            7785=>S_L,537=>S_L,351=>S_L,575=>S_L,42921=>S_L,42885=>S_L,7835=>S_L,
            116=>T_L,9443=>T_L,65364=>T_L,7787=>T_L,7831=>T_L,357=>T_L,7789=>T_L,539=>T_L,355=>T_L,7793=>T_L,7791=>T_L,
            359=>T_L,429=>T_L,648=>T_L,11366=>T_L,42887=>T_L,
            42793=>TZ_LL,
            117=>U_L,9444=>U_L,65365=>U_L,249=>U_L,250=>U_L,251=>U_L,361=>U_L,7801=>U_L,363=>U_L,7803=>U_L,365=>U_L,
            252=>U_L,476=>U_L,472=>U_L,470=>U_L,474=>U_L,7911=>U_L,367=>U_L,369=>U_L,468=>U_L,533=>U_L,535=>U_L,
            432=>U_L,7915=>U_L,7913=>U_L,7919=>U_L,7917=>U_L,7921=>U_L,7909=>U_L,7795=>U_L,371=>U_L,7799=>U_L,7797=>U_L,
            649=>U_L,118=>V_L,9445=>V_L,65366=>V_L,7805=>V_L,7807=>V_L,651=>V_L,42847=>V_L,652=>V_L,
            42849=>VY_LL,
            119=>W_L,9446=>W_L,65367=>W_L,7809=>W_L,7811=>W_L,373=>W_L,7815=>W_L,7813=>W_L,7832=>W_L,7817=>W_L,11379=>W_L,
            120=>X_L,9447=>X_L,65368=>X_L,7819=>X_L,7821=>X_L,
            121=>Y_L,9448=>Y_L,65369=>Y_L,7923=>Y_L,253=>Y_L,375=>Y_L,7929=>Y_L,563=>Y_L,7823=>Y_L,255=>Y_L,7927=>Y_L,
            7833=>Y_L,7925=>Y_L,436=>Y_L,591=>Y_L,7935=>Y_L,
            122=>Z_L,9449=>Z_L,65370=>Z_L,378=>Z_L,7825=>Z_L,380=>Z_L,382=>Z_L,7827=>Z_L,7829=>Z_L,438=>Z_L,549=>Z_L,
            576=>Z_L,11372=>Z_L,42851=>Z_L
    };

    static Map<Integer, List<Integer>> GERMAN_DOUBLING_MAP = new Map<Integer, List<Integer>>{
            228=>AE_LL,246=>OE_LL,252=>UE_LL
    };

    //lower case strings only, preferably cleaned from non-letter characters
    public static String normalizeAndReplaceDiacritics(String str, Boolean doubleGermanLetters) {
        if (str == null) {
            return null;
        }
        List<Integer> result = new List<Integer>();
        //List<Integer> misses = new List<Integer>();
        for (Integer chr : str.toLowerCase().getChars()) {
            //english lowercase is from 97 to 122
            if (chr > 96 && chr < 123) {
                result.add(chr);
            } else {
                if (DIACRITIC_MAP.containsKey(chr)) {
                    if (doubleGermanLetters && GERMAN_DOUBLING_MAP.containsKey(chr)) {
                        result.addAll(GERMAN_DOUBLING_MAP.get(chr));
                    } else {
                        result.addAll(DIACRITIC_MAP.get(chr));
                    }
                }
            }
        }
        return String.fromCharArray(result);
    }
}