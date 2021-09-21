import java.sql.*;
import java.util.Scanner; 
public class Entry {
    private static final Scanner S = new Scanner(System.in);
    Statement crnst = null; 
    private static Connection c = null;
    private static ResultSet rs = null;

    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.jdbc.Driver");

            c = DriverManager.getConnection("jdbc:mysql://localhost:3306/cmpdambr","cmpdambr","atmo4qui"); // ToDo : Specify Connection String !
            Statement s = c.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);

            rs = s.executeQuery("SELECT loan.'code', loan.'no', loan.'due'FROM loan WHERE (YEAR(taken) = YEAR(CURRENT_DATE())) AND (`return` IS NULL) ORDER BY DATE AESC");
                   

            String choice = "";

            do {
                System.out.println("-- MAIN MENU --");
                System.out.println("1 - Browse ResultSet");
                System.out.println("2 - Invoke Procedure");
                System.out.println("Q - Quit");
                System.out.print("Pick : ");

                choice = S.next().toUpperCase();

                switch (choice) {
                    case "1" : {
                        browseResultSet();
                        break;
                    }
                    case "2" : {
                        invokeProcedure();
                        break;
                    }
                }
            } while (!choice.equals("Q"));

            c.close();

            System.out.println("Bye Bye :)");
        }
        catch (Exception e) {
            System.err.println(e.getMessage());
        }
    }

    private static void browseResultSet() throws Exception {
        // ToDo : Ensure ResultSet Contains Rows !
        System.out.println("code \t loan \t no \t taken \t due");
        do
        {
            int copycode = rs.getInt("code"); 
            int student_num = rs.getInt("no"); 
            Date loan_taken = rs.getDate("taken"); 
            Date loan_due = rs.getDate("due"); 
        } while (rs.next()));
         
        // ToDo : Iterate Through ResultSet's Rows !
        try {
            crnst =  con.createStatement();
        ResultSet rs = crnst.executeQuery(query);
        while (rs.next()) {
        
        int copycode = rs.getString("code");
        int student_num = rs.getString("no");
        Date loan_taken = rs.getString("taken");
        Date loan_due = rs.getString("due");
        System.out.println(copycode + "\t" + student_num + "\t" + loan_taken + 
        "\t" + due);
        }  
    } catch (Exception e) {JDBC_MySQL.printException(e);
    } finally {
       if (crnst != null) {crnst.close(); }
        }
    }

    private static void invokeProcedure() throws Exception {
        // ToDo : Accept Book ISBN & Student No !
        Scanner reader = new Scanner(System.in);
        System.out.println("enter Book ISBN: \t");
        String t = reader.nextString();  
        reader.close(); 

        Scanner reader = new Scanner(System.in);
        System.out.println("enter student number \t");
        String t = reader.nextString(); 
    
        CallableStatement cs = c.prepareCall("{CALL P_generate_loan(?,?)}");
        cs.setString (1, "code");
        cs.setString (2, "no");
        cs.setString (3, "taken");
        cs.setString (4, "due");
        // ToDo : Declare, Configure & Invoke CallableStatement !
    }
}
