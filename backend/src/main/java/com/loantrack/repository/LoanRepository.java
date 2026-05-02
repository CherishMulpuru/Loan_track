package com.loantrack.repository;

import com.loantrack.entity.Loan;
import com.loantrack.entity.Loan.LoanStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LoanRepository extends JpaRepository<Loan, Long> {

    List<Loan> findByUserId(Long userId);

    List<Loan> findByUserIdAndStatus(Long userId, LoanStatus status);

    Optional<Loan> findByLoanNumber(String loanNumber);

    @Query("SELECT l FROM Loan l WHERE l.user.id = :userId AND l.id = :loanId")
    Optional<Loan> findByIdAndUserId(@Param("loanId") Long loanId, @Param("userId") Long userId);

    boolean existsByLoanNumber(String loanNumber);
}
